local Connection = require(script.Connection)
local Promise = require(script.Parent.Parent.Promise) -- packages will be siblings in the datamodel

local function eachNode(node, fn, ...)
    while node do
        fn(node, ...)
        node = node._next
    end
end

local function fireDeferredConnection(node, ...)
    task.defer(node._fn, ...)
end

local function fireImmediateConnection(node, ...)
    task.spawn(node._fn, ...)
end

--[=[
    Luau TrueSignal implementation

    @class TrueSignal
]=]
local TrueSignal = {}
TrueSignal.__index = TrueSignal

--[=[
    Constructs a new TrueSignal object.

    @return TrueSignal
]=]
function TrueSignal.new(queueing, deferred)
    local self = setmetatable({}, TrueSignal)

    --[=[
        Tells whether or not the TrueSignal is currently firing arguments or not
        (this should only be true if the environment it is being read from is within a handler call)
    ]=]
    self.firing = false

    if queueing then
        self._queue = {}
    end

    if deferred then
        self._deferred = true
    end

    return self
end

--[=[
    Fires the TrueSignal with the optional passed arguments. This method makes optimizations by recycling threads in cases where connections don't yield if deferred is false.

    @param ... any
]=]
function TrueSignal:fire(...)
    local head = self._head

    if head == nil then
        if self.queueing then
            table.insert(self._queue, table.pack(...))
        end
    else
        self.firing = true

        eachNode(head, self._deferred and fireDeferredConnection or fireImmediateConnection, ...)

        local newHead, newTail

        eachNode(head, function(node)
            if node.connected then
                if not newHead then
                    newHead = node
                    newTail = node
                else
                    newTail._next = node
                    newTail = node
                end
            end
        end)
        
        self._head = newHead
        self.firing = false
    end
end

--[=[
    Empties any queued arguments that may have been added when fire was called with no connections.
]=]
function TrueSignal:flush()
    if self._queue then
        table.clear(self._queue)
    end
end

--[=[
    Yields the current thread until the TrueSignal is fired and returns what was fired

    @yields
    @return any
]=]
function TrueSignal:wait()
    return self:promise():expect()
end

--[=[
    Returns a promise that resolves the next time the TrueSignal is fired

    @return Promise
]=]
function TrueSignal:promise()
    return Promise.new(function(resolve, _, onCancel)
        if self._queue and self._queue[1] then
            resolve(table.unpack(table.remove(self._queue, 1)))
            return
        end

        local connection

        onCancel(function()
            connection:disconnect()
        end)

        connection = self:connect(function(...)
            connection:disconnect()
            resolve(...)
        end)
    end)
end

--[=[
    Connects a handler function to the TrueSignal so that it can be called when it's fired.

    @param fn function
    @return Connection
]=]
function TrueSignal:connect(fn)
    local connection = Connection.new(self, fn)
    local head = self._head

    connection._next = head
    self._head = connection

    if not head then
        while self._queue and self._queue[1] and self._head do
            task.spawn(fn, table.unpack(table.remove(self._queue, 1)))
        end
    end

    return connection
end

--[=[
    Flushes the TrueSignal and disconnects all connections
]=]
function TrueSignal:destroy()
    self:flush()

    local head = self._head

    eachNode(head, function(node)
        node.connected = false
    end)

    self._head = nil
    self.destroyed = true
end

--[[
    Include PascalCase RbxScriptTrueSignal interface
]]
TrueSignal.Destroy = TrueSignal.destroy
TrueSignal.Wait = TrueSignal.wait
TrueSignal.Connect = TrueSignal.connect

return TrueSignal