-- Param File to load
-- load message  if its loaded 
function LoadFile(FilePath, LoadMsg)
    local lua = ReadFile(FilePath)
    if not lua then
        print(FilePath .. " Does not exist")
    end
    local func,err = loadstring(lua)
    if err then
        error(err,0)
    else
        pcall(func)
        if LoadMsg then
            print(LoadMsg)
        end
    end
end