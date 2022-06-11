local package = game.ServerScriptService.TrueSignal

package.Parent = game.ReplicatedStorage.Packages

require(package.Parent.TestEZ).TestBootstrap:run({
    package["TrueSignal.spec"],
    package["Connection.spec"],
})
