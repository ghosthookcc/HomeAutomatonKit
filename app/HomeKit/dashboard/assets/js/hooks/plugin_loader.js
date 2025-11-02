import { hookRegistry } from "./hooks_registry.js";

export async function loadPlugin(plugin_name) 
{
    try 
    {
        // ?t=${Date.now()}
        const module = await import(`/plugins/${plugin_name}/js/app.js`);
        console.log(module);
        if (module.hooks) 
        {
            for (const [name, definition] of Object.entries(module.hooks)) 
            {
                hookRegistry.register(name, definition);
            }
            console.log(`[+][PluginLoader][${plugin_name}] Loaded Plugin . . .`);
            reapplyHooks();
        }
        else
        {
            console.warn(`[/][PluginLoader][${plugin_name}] No hooks found to export . . .`);
        }
    } 
    catch (errno) 
    {
        console.error(`[-][PluginLoader][${plugin_name}] Failed to load:`, errno);
    }
}

export function unloadPlugin(plugin_name) 
{
    const hook = hookRegistry.hooks[plugin_name];
    if (hook) 
    {
        document.querySelectorAll(`[phx-hook="${plugin_name}"]`)
                .forEach((el) => el.__x_hook__?.destroyed?.());
        hookRegistry.unregister(plugin_name);
    }
}

export function reapplyHooks() 
{
    document.querySelectorAll("[phx-hook]").forEach((el) => 
    {
        const hookName = el.getAttribute("phx-hook");
        const newHook = hookRegistry.hooks[hookName];
        if (!newHook) return;

        const existing = el.__x_hook__;
        if (existing) return;

        const hook = Object.create(newHook);
        hook.el = el;
        hook.mounted?.call(hook);
        el.__x_hook__ = hook;
    });
}
