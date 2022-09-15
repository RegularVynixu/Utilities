export type DiscordInvitationModule = {
    -- print(#DiscordInvitationModule.Connections)
    Connections: {
        [number]: RBXScriptConnection
    },
    -- DiscordInvitationModule.Prompt({invite = "https://discord.gg/example", name = "Example Invite"})
    Prompt: (
        {
            invite: string,
            name: string?
        }
    ) -> (),
    -- DiscordInvitationModule.Join("https://discord.gg/example")
    Join: (invite: string) -> (),
    -- print(DiscordInvitationModule.Gui:GetFullName())
    Gui: ScreenGui
}

--- The Discord invitation module, used to prompt invites to users.
local DiscordInvitationModule: DiscordInvitationModule = require(...)
