function ULibSync.checkTableForChangedValues(originalTable, updatedTable)
   local valuesChanges = {}
   for key, value in pairs(updatedTable) do
      if originalTable[key] ~= value or not originalTable[key] then
         valuesChanges[key] = value
      end
   end
   return valuesChanges
end
