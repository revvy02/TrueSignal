local RunService = game:GetService("RunService")

local Promise = require(script.Parent.Parent.Promise)

local TrueSignal = require(script.Parent.TrueSignal)
local Connection = require(script.Parent.Signal.Connection)

return function()
    describe("Signal.new", function()
        it("should create a new signal object", function()
            local signal = TrueSignal.new()

            expect(signal).to.be.a("table")
            expect(getmetatable(signal)).to.equal(TrueSignal)

            signal:destroy()
        end)

        it("should work if queueing is false and deferred is false", function()
            local signal = TrueSignal.new(false, false)

            expect(signal).to.be.a("table")
            expect(getmetatable(signal)).to.equal(TrueSignal)

            signal:destroy()
        end)

        it("should work if queueing is true and deferred is false", function()
            local signal = TrueSignal.new(true, false)

            expect(signal).to.be.a("table")
            expect(getmetatable(signal)).to.equal(TrueSignal)

            signal:destroy()
        end)

        it("should work if queueing is true and deferred is true", function()
            local signal = TrueSignal.new(true, true)

            expect(signal).to.be.a("table")
            expect(getmetatable(signal)).to.equal(TrueSignal)

            signal:destroy()
        end)

        it("should work if queueing is false and deferred is true", function()
            local signal = TrueSignal.new(false, true)

            expect(signal).to.be.a("table")
            expect(getmetatable(signal)).to.equal(TrueSignal)

            signal:destroy()
        end)
    end)
    
    describe("Signal:fire", function()
        it("should fire an activating connection properly if args are queued and deferred", function()
            local signal = TrueSignal.new(true, true)

            local done = {}

            signal:fire(1)
            signal:fire(2)

            local connection = signal:connect(function(index)
                done[index] = true
            end)

            expect(done[1]).to.be.ok()
            expect(done[2]).to.be.ok()

            connection:destroy()
            signal:destroy()
        end)

        it("should fire an activating connection properly if args are queued and not deferred", function()
            local signal = TrueSignal.new(true, false)

            local done = {}

            signal:fire(1)
            signal:fire(2)

            local connection = signal:connect(function(index)
                done[index] = true
            end)

            expect(done[1]).to.be.ok()
            expect(done[2]).to.be.ok()

            connection:destroy()
            signal:destroy()
        end)

        it("should fire connections properly if not queueing and not deferred", function()
            local signal = TrueSignal.new(false, false)
            local done1, done2 = {}, {}

            signal:fire(1)
            signal:fire(2)

            local connection1 = signal:connect(function(index)
                done1[index] = true
            end)

            expect(done1[1]).to.never.be.ok()
            expect(done1[2]).to.never.be.ok()

            local connection2 = signal:connect(function(index)
                done2[index] = true
            end)

            expect(done2[1]).to.never.be.ok()
            expect(done2[2]).to.never.be.ok()

            signal:fire(3)
            signal:fire(4)

            expect(done1[3]).to.be.ok()
            expect(done1[4]).to.be.ok()

            expect(done2[3]).to.be.ok()
            expect(done2[4]).to.be.ok()

            connection1:destroy()
            connection2:destroy()
            signal:destroy()
        end)

        it("should fire connections properly if queueing and not deferred", function()
            local signal = TrueSignal.new(true, false)
            local done1, done2 = {}, {}

            signal:fire(1)
            signal:fire(2)

            local connection1 = signal:connect(function(index)
                done1[index] = true
            end)

            expect(done1[1]).to.be.ok()
            expect(done1[2]).to.be.ok()

            local connection2 = signal:connect(function(index)
                done2[index] = true
            end)

            expect(done2[1]).to.never.be.ok()
            expect(done2[2]).to.never.be.ok()

            signal:fire(3)
            signal:fire(4)

            expect(done1[3]).to.be.ok()
            expect(done1[4]).to.be.ok()

            expect(done2[3]).to.be.ok()
            expect(done2[4]).to.be.ok()

            connection1:destroy()
            connection2:destroy()
            signal:destroy()
        end)

        it("should fire connections properly if queueing and deferred", function()
            local signal = TrueSignal.new(true, true)
            local done1, done2 = {}, {}

            signal:fire(1)
            signal:fire(2)

            local connection1 = signal:connect(function(index)
                done1[index] = true
            end)

            expect(done1[1]).to.be.ok()
            expect(done1[2]).to.be.ok()

            local connection2 = signal:connect(function(index)
                done2[index] = true
            end)

            expect(done2[1]).to.never.be.ok()
            expect(done2[2]).to.never.be.ok()

            signal:fire(3)
            signal:fire(4)

            expect(done1[3]).to.never.be.ok()
            expect(done1[4]).to.never.be.ok()
            
            expect(done2[3]).to.never.be.ok()
            expect(done2[4]).to.never.be.ok()

            local thread = coroutine.running()

            task.defer(function()
                task.spawn(thread)
            end)

            coroutine.yield()

            expect(done1[3]).to.be.ok()
            expect(done1[4]).to.be.ok()
            
            expect(done2[3]).to.be.ok()
            expect(done2[4]).to.be.ok()

            connection1:destroy()
            connection2:destroy()
            signal:destroy()
        end)

        it("should fire connections properly if not queueing and deferred", function()
            local signal = TrueSignal.new(false, false)
            local done1, done2 = {}, {}

            signal:fire(1)
            signal:fire(2)

            local connection1 = signal:connect(function(index)
                done1[index] = true
            end)

            expect(done1[1]).to.never.be.ok()
            expect(done1[2]).to.never.be.ok()

            local connection2 = signal:connect(function(index)
                done2[index] = true
            end)

            expect(done2[1]).to.never.be.ok()
            expect(done2[2]).to.never.be.ok()

            signal:fire(3)
            signal:fire(4)

            expect(done1[3]).to.never.be.ok()
            expect(done1[4]).to.never.be.ok()
            
            expect(done2[3]).to.never.be.ok()
            expect(done2[4]).to.never.be.ok()

            local thread = coroutine.running()

            task.defer(function()
                task.spawn(thread)
            end)

            coroutine.yield()
            
            expect(done1[3]).to.be.ok()
            expect(done1[4]).to.be.ok()
            
            expect(done2[3]).to.be.ok()
            expect(done2[4]).to.be.ok()

            connection1:destroy()
            connection2:destroy()
            signal:destroy()
        end)

        it("should fire disconnected connections that were disconnected during :fire if queueing and not deferred", function()
            local signal = TrueSignal.new(true, false)
            local done0, done1 = false, false

            local connection = signal:connect(function(bool)
                done0 = bool
            end)

            signal:connect(function(bool)
                done1 = bool
                connection:disconnect()
            end)

            signal:fire(true)

            expect(done0).to.equal(true)
            expect(done1).to.equal(true)

            signal:destroy()
        end)

        it("should not fire disconnected connections that were disconnected outside :fire if not deferred", function()
            local signal = Signal.new()
            local done0, done1 = false, false

            local connection = signal:connect(function(bool)
                done0 = bool
            end)

            signal:connect(function(bool)
                done1 = bool
            end)

            connection:disconnect()
            signal:fire(true)

            expect(done0).to.equal(false)
            expect(done1).to.equal(true)
            
            signal:destroy()
        end)

        it("should fire connections connected at the time of fire call with the passed args at the end of the frame if deferred", function()
            local signal = Signal.new()
            signal:enableDeferred()

            local done0, done1, done2 = false, false, false

            signal:connect(function(bool)
                done0 = bool
            end)

            signal:connect(function(bool)
                done1 = bool
            end)

            signal:fire(true)

            signal:connect(function(bool)
                done2 = bool
            end)

            -- Should be false since the fire call is deferred until the end of the frame

            expect(done0).to.equal(false)
            expect(done1).to.equal(false)
            expect(done2).to.equal(false)

            RunService.RenderStepped:Wait()

            expect(done0).to.equal(true)
            expect(done1).to.equal(true)
            expect(done2).to.equal(false)

            signal:destroy()
        end)

        it("should fire disconnected connections at the end of the frame that were disconnected from between the fire call to the end of the frame if deferred", function()
            local signal = Signal.new()
            signal:enableDeferred()

            local done0, done1 = false, false

            signal:connect(function(bool)
                done0 = bool
            end)

            signal:connect(function(bool)
                done1 = bool
            end)

            signal:fire(true)

            expect(done0).to.equal(false)
            expect(done1).to.equal(false)

            signal:disconnectAll()
            RunService.RenderStepped:Wait()

            expect(done0).to.equal(true)
            expect(done1).to.equal(true)

            signal:destroy()
        end)

        it("should not fire disconnected connections at the end of the frame that were disconnected outside the deferred fire call to the end of the frame if deferred", function()
            local signal = Signal.new()
            signal:enableDeferred()

            local done = false

            signal:connect(function(bool)
                done = bool
            end)
            
            signal:disconnectAll()
            signal:fire(true)

            expect(done).to.equal(false)

            RunService.RenderStepped:Wait()

            expect(done).to.equal(false)

            signal:destroy()
        end)

        it("should not fire connected connections that were connected after the fire call if deferred", function()
            local signal = Signal.new()
            signal:enableDeferred()

            local done = false

            signal:fire(true)

            signal:connect(function(bool)
                done = bool
            end)

            RunService.RenderStepped:Wait()
            expect(done).to.equal(false)

            signal:fire(true)

            RunService.RenderStepped:Wait()
            expect(done).to.equal(true)

            signal:destroy()
        end)
    end)

    describe("Signal:connect", function()
        it("should return a connection that is connected initially", function()
            local signal = TrueSignal.new()
            local connection = signal:connect(function() end)

            expect(connection.connected).to.equal(true)

            signal:destroy()
        end)

        it("should throw within connection handler if connection is disconnected from inside handler if args are queued", function()
            local signal = TrueSignal.new(true)

            local fails = 0
            local connection

            signal:fire()
            signal:fire()
            signal:fire()

            connection = signal:connect(function()
                local success = pcall(function()
                    connection:disconnect()
                end)

                if not success then
                    fails += 1
                end
            end)

            expect(fails).to.equal(3)

            connection:destroy()
            signal:destroy()
        end)

        it("should not throw if connection is disconnected from inside handler if args not queued", function()
            local signal = TrueSignal.new(true)

            local passes = 0
            local connection

            connection = signal:connect(function()
                local success = pcall(function()
                    connection:disconnect()
                end)

                if success then
                    passes += 1
                end
            end)

            expect(passes).to.equal(0)

            signal:fire()

            expect(passes).to.equal(1)

            connection:destroy()
            signal:destroy()
        end)

        it("should call the handler with all queued args if args are queued", function()
            local signal = TrueSignal.new(true)
            signal:enableQueueing()

            local output = {}

            signal:fire(1)
            signal:fire(2)
            signal:fire(10)

            signal:connect(function(value)
                table.insert(output, value)
            end)

            expect(output[1]).to.equal(1)
            expect(output[2]).to.equal(2)
            expect(output[3]).to.equal(10)

            signal:destroy()
        end)
    end)

    
    describe("Signal:wait", function()
        it("should yield until signal is fired and return passed args from the fire call", function()
            local signal = TrueSignal.new()
            local message1, message2

            task.spawn(function()
                message1, message2 = signal:wait()
            end)

            expect(message1).to.never.be.ok()
            expect(message2).to.never.be.ok()

            signal:fire("two", "messages")

            expect(message1).to.equal("two")
            expect(message2).to.equal("messages")

            signal:destroy()
        end)

        it("it should return args popped from the queue if args are queued", function()
            local signal = TrueSignal.new(true)

            signal:fire(1)
            signal:fire(2)
            signal:fire(3)

            local popped1 = signal:wait()
            local popped2 = signal:wait()
            local popped3 = signal:wait()

            expect(popped1).to.equal(1)
            expect(popped2).to.equal(2)
            expect(popped3).to.equal(3)

            signal:destroy()
        end)
    end)
    
    describe("Signal:promise", function()
        it("should return a promise that resolves with the args passed in the next fire call if args aren't queued", function()
            local signal = TrueSignal.new(false)
            local promise = signal:promise()

            expect(promise:getStatus()).to.equal(Promise.Status.Started)

            signal:fire("message")

            expect(promise:getStatus()).to.equal(Promise.Status.Resolved)
            expect(promise:expect()).to.equal("message")

            signal:destroy()
        end)

        it("should return a promise that resolves with args popped from the queue if args are queued", function()
            local signal = TrueSignal.new(true)

            signal:fire(0)
            signal:fire(1)
            
            expect(signal:promise():expect()).to.equal(0)
            expect(signal:promise():expect()).to.equal(1)

            signal:destroy()
        end)
    end)
    


    describe("Signal:destroy", function()
        it("should set destroyed field to true", function()
            local signal = TrueSignal.new()

            signal:destroy()

            expect(signal.destroyed).to.equal(true)
        end)

        it("should disconnect all connected connections", function()
            local signal = TrueSignal.new()

            local connection1 = signal:connect(function() end)
            local connection2 = signal:connect(function() end)

            expect(connection1.connected).to.equal(true)
            expect(connection2.connected).to.equal(true)

            signal:destroy()

            expect(connection1.connected).to.equal(false)
            expect(connection2.connected).to.equal(false)
        end)
    end)
end