
#Script written by Faisal Alsohaibani under supervision of Mr.Dinosaur 


function Survey-Host { 

# This function will collect information about the host system and print it to a file name tha is passed by the user.

    param(

         [parameter(ParameterSetName='1' , Mandatory = $true)]$filename

     )

         echo "`n" >>$filename
         echo "Computer name: $env:COMPUTERNAME  ">>$filename

         $DateTime = Get-Date 
         echo "Date & Time: $DateTime  " >>$filename

         $OSVersion = (Get-CimInstance Win32_OperatingSystem).Version 
         echo "OS Version: $OSVersion ">>$filename

         $ProcessesList = (Get-Process | Group-Object SessionId ) 
         echo "List of processes grouped by session: `n">>$filename
         echo $ProcessesList >>$filename
         echo "`n">>$filename

         find-Listening-Processes 


  function find-Listening-Processes{
  
 # This function will start by returning the owning process ID for every "listening" tcp port in the host.
 # It will then return the PID for every running process in the host.
 # Last it will match between the ID's and return the process name for every open listening tcp port in the host.
 # The output is passed to the file supplyed in the survey-host function.
  

    $ProcessesIDs =   (Get-NetTCPConnection | Where-Object {$_.State -eq "Listen"} | select -Expand OwningProcess)
    $ProcessesList =  (Get-Process | Select -Expand id )
    $result = @()
 
          foreach ( $id in $ProcessesIDs ) { 
                foreach ( $pidd in $ProcessesList){    
                    if($pidd -eq $id ) {
                         $result = $result + "`n" +  (Get-Process | Where-Object {$_.Id -eq "$pidd" } | Select -expand ProcessName )
                       }
                  }
    
          } 


     echo " List of processes names that has an open listening port: ">>$filename
     echo "$result">>$filename



}

} 


function Hash-Directory {


# This function takes two parameters dir: the Directory to start with , filename: the name of the file to output to.
# It will then serach the directory recursvly and hash every file and output those hashes to the supplied file.
# Note that the supplied directory must be a subdirectory of PWD.

    param(

        [parameter(Mandatory=$true)] $dir ,
        [parameter(Mandatory=$false)] $filename="fileHashes"

    )

        $fulldir = Resolve-path $dir 
        Get-ChildItem -path $fulldir -Recurse | Get-FileHash >$filename 

}


function Create-Services-Baselin {

    # This function will create a file that stores baseline for the START and IMAGEPATH values for each services in HKLM:\SYSTEM\CurrentControlSet\Services.

    $BaseLineFile = "C:\Users\$env:USERNAME\Baselines\ServicesBaseLine.txt"
    Get-ChildItem -Path HKLM:\SYSTEM\CurrentControlSet\Services | Get-ItemProperty | Select-Object start,imagepath >$BaseLineFile

}


function Check-Services-Baselin{

    # This function creates a file and compare it with the services baseline and show the diffreneces if there is any.
    # If there is no differance it will show nothing.
    # Then it deletes the file while the baseline is kept.
 

    $tempfile = "C:\Users\$env:USERNAME\Baselines\ServicesCompareBaseLine.txt"

    Get-ChildItem -Path HKLM:\SYSTEM\CurrentControlSet\Services | Get-ItemProperty | Select-Object start,imagepath >$tempfile
    Compare-Object -ReferenceObject $(Get-Content $tempfile) -DifferenceObject $(Get-Content C:\Users\$env:USERNAME\Baselines\ServicesBaseLine.txt)

    rm $tempfile

}



