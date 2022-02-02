<table> Advertisements {
    <void> function Advertisements:Add(<table> {
        <string> Image, -- Url of the image you wish to be displayed
        <string> Invite, -- Optional, once clicked on, user will be redirected to linked Discord server
        <int> Duration, -- Optional, 10 by default, max. 30 (screen-time in seconds)
    })
    -- [i] Construct an advertisement, with a custom banner and an optional Discord invite

    <void> function Advertisements:Remove(<table> activeAdvertisement)
    -- [i] Rid an active advertisement, utilising this isn't much of a necessity in practise
}
  
return <table> Advertisements
