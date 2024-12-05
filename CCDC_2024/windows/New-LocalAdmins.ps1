$Names = @('cesar_la', 'cam_la', 'marshall_la')
foreach ($name in $Names){net user /add /Y $name '#!C0@stCCDCteam!';net localgroup /add /Y 'Administrators' $name;net localgroup /add /Y 'Remote Desktop Users' $name}
