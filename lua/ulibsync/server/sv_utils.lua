function ULibSync.checkTableForChangedValues(originalTable, updatedTable)
   local valuesChanged = {}
   for key, value in pairs(updatedTable) do
      if originalTable[key] ~= value or not originalTable[key] then
         valuesChanged[key] = value
      end
   end
   return valuesChanged
end
