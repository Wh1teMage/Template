for _, v: ModuleScript in pairs(script.Parent:GetChildren()) do
	require(v)
end

return {}
