export class HookRegistry 
{
    constructor() 
    {
        this._hooks = {};
    }

    register(name, definition)
    {
        this._hooks[name] = definition;
        console.log(`[HookRegistry][${name}] Registered hook`);
    }
    unregister(name)
    {
        delete this._hooks[name];
        console.log(`[HookRegistry][${name}] Unregistered hook`);
    }

    getHooks()
    {
        return this._hooks;
    }
}

export const hookRegistry = new HookRegistry();
