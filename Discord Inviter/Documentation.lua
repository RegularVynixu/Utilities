<table> Inviter {
    <void> function Inviter.Prompt(<table> {
        <string> invite,
        <string> name, -- [optional] overwrites the displayed server name on the prompt
    })
    -- [i] Prompts an invite in-game, user can make the decision to join or not. This will also prompt on their Discord client.
    
    <void> function Inviter.Join(<string> invite)
    -- [i] Skips the in-game prompt and sends a request to join the server, will still prompt on the user's Discord client.
}
  
return <table> Inviter
