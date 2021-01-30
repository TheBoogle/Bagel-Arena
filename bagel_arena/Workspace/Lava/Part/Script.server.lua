while wait() do
	script.Parent.Beam.CurveSize0 = math.sin(tick())
	script.Parent.Beam.CurveSize1 = -math.cos(tick())
end