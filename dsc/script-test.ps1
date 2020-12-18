Configuration ScriptTest
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node localhost
    {
        Script ScriptExample
        {
            SetScript = {
                $sw = New-Object System.IO.StreamWriter("C:\temp\TestFile.txt")
                $sw.WriteLine("Some sample string")
                $sw.Close()
            }
            TestScript = { Test-Path "C:\temp\TestFile.txt" }
            GetScript = { @{ Result = (Get-Content C:\temp\TestFile.txt) } }
        }
    }
}

# Generate .MOF File
ScriptTest