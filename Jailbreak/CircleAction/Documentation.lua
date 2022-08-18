-- Create A Spec
<function> CircleAction.Create(<table> data{
    <string> Name, -- required
    <instance> Part, -- required
    <boolean> Timed,
    <int> Duration,
    <int> Dist,
    <int> Priority,
    <function> Callback,
}) --[[ Returns a function which will destroy the created spec ]]--

-- Destroy A Spec
<bool> CircleAction.Remove(<table> spec) --[[ Returns a boolean depending on if destruction was successful ]]--
