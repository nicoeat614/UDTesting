#region Theme and Custom Colors

#Font Color for UDParagraph
$ParagraphColor = @{
    Color ="#ffffff" # White
}

#Colors for Nav UDDashboard for Homepage
$NavDashColors = @{
    NavBarColor = '#173654' 
    NavBarFontColor = '#f1f1f1'  
}

#Theme
$ThemeColor = New-UDTheme -Name "Lotto" -Definition @{
  UDDashboard = @{
      BackgroundColor = '#f1f1f1'  
      FontColor = "#ffffff" 
  }
  UDInput = @{ 
      BackgroundColor = "#decc90" 
      FontColor = "#FFFFFF"
  }
  #Note: This one doesn't work for some reason. Had to put this in New-UDCard.
  UDCard = @{ 
      BackgroundColor = '#173654'   
      FontColor = "#decc90" 
  }
  UDTable = @{
      BackgroundColor = "#c6d5c2" 
      FontColor = '#f1f1f1' 
  }
  UDFooter = @{
      BackgroundColor = '#173654'  
      FontColor = '#f1f1f1'  
  }

  '.btn' = @{
    'color' = "#ffffff"
    'background-color' = "#c6d5c2" 
  }

  '.btn:hover' = @{
    'background-color' = "#90a2de" 
  }

  '.btn-floating' = @{
    'color' = "#555555"
    'background-color' = "#c6d5c2" 
  }

  '.btn-floating:hover' = @{
   'background-color' =  "#decc90"   
   }

}

#endregion Theme and Custom Colors


#region Variables

#States
$States = @"
    Alabama - AL
    Alaska - AK
    Arizona - AZ
    Arkansas - AR
    California - CA
    Colorado - CO
    Connecticut - CT
    Delaware - DE
    Florida - FL
    Georgia - GA
    Hawaii - HI
    Idaho - ID
    Illinois - IL
    Indiana - IN
    Iowa - IA
    Kansas - KS
    Kentucky - KY
    Louisiana - LA
    Maine - ME
    Maryland - MD
    Massachusetts - MA
    Michigan - MI
    Minnesota - MN
    Mississippi - MS
    Missouri - MO
    Montana - MT
    Nebraska - NE
    Nevada - NV
    New Hampshire - NH
    New Jersey - NJ
    New Mexico - NM
    New York - NY
    North Carolina - NC
    North Dakota - ND
    Ohio - OH
    Oklahoma - OK
    Oregon - OR
    Pennsylvania - PA
    Rhode Island - RI
    South Carolina - SC
    South Dakota - SD
    Tennessee - TN
    Texas - TX
    Utah - UT
    Vermont - VT
    Virginia - VA
    Washington - WA
    West Virginia - WV
    Wisconsin - WI
    Wyoming - WY
"@

$States = $States -split "`n" -replace "-","=" 
$States = $States | % {$_.trim()} | % { 
                    [pscustomobject]@{
                        StateName = $_ -replace ".\=\s\w+$"
                        Abbrev = $_ -replace "^(\w+\s=\s|\w+\s\w+\s=\s)"
                        }
    }

$statesabb = $States.Abbrev

#JSON Data
$col = ConvertFrom-Json -InputObject (Get-Content .\UDTestData.json -raw)

#Footer
$Footer = New-UDFooter -Copyright "Doofus" 

#endregion Variables


#region Pages

#HomePage
$HomePage = New-UDPage -Name "Home" -Icon home -Content {
New-UDRow -Columns {
    New-UDColumn -SmallOffset 4
    New-UDColumn -SmallSize 3 -Content {
            New-UDHtml -Markup "<div class='search' style='padding:10px;margin:25px;font-weight:700;color:#173654;text-align:center'><h6>
                                Find or Search for Scratcher</h6></div>" 

                    New-UDInput -Endpoint {
                   
                       Param([ValidateSet("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN`
                            ", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT",`
                             "VA", "WA", "WV", "WI", "WY")]$dropdown,
                        $searchbar)                       
                                                    
                        New-UDInputAction -Toast "Retrieving scratchers for $dropdown" 
                        New-UDInputAction -RedirectUrl "/Scratcher/$dropdown"
                        
                       
                        } -Content {
                            New-UDInputField -Name "Search" -Type textbox 
                            New-UDInputField -Name "dropdown" -Placeholder "Select State" -Type select -Values $($Global:statesabb) 

                   }
             }
       }
 }


#Dynamic Pages
$Global:DynamicPage = New-UDPage -Url "/Scratcher/:dropdown" -Endpoint {
                            param($dropdown, $scratchref)

    if ($dropdown -eq "VA") {

               New-UDRow -Columns {
                    New-UDColumn -SmallOffset 4
                    New-UDColumn -SmallSize 3 -Content {
                            New-UDHtml -Markup "<div class='VAsearch' style=color:#173654;text-align:center'><h3>
                                                Virginia Sratchers</h3></div>" 
                                                        }
                                   }                                                  
               New-UDRow {
                    New-UDColumn -Size 12 {
                        New-UDLayout -Columns 3 -Content {           
                            Foreach ($item in $col) {                                           
                                New-UDCard -BackgroundColor '#173654'-FontColor "#decc90" -Title $item.name -id $item.name -Content {
                                New-UDParagraph -Text "Game ID: $($item.'Game ID')" @ParagraphColor
                                New-UDParagraph -Text "Top Prize Odds: $($item.'Top Prize Odds')" @ParagraphColor
                                New-UDParagraph -Text "Listed Odds: $($item.'Any Prize Odds')" @ParagraphColor
                                New-UDParagraph -Text "True Odds: $($item.'True Odds')"  @ParagraphColor                                    
                                New-UDButton -Id "$($item.name + '_info')" -Icon plus -Floating -IconAlignment right -OnClick {                                 
                                $scratchref = (Get-UDElement -Id $item.name).Attributes["value"]
                                Invoke-UDRedirect -Url  "/Scratcher/$dropdown/$scratchref" 
                                                                              }                        
                                                                    } 
                                                        }
                                            }
                                }
                    }
          }

    Else {
        New-UDCard -Title $dropdown
            }

} #End of HomePage

#Dynamic Page for UDButton url redirect
$Global:ScratcherPage = New-UDPage -Url "/Scratcher/:dropdown/:scratchref" -Endpoint {
        param($dropdown, $scratchref)
    
        $newref = $col | ? {$scratchref -contains $_.name } | Select *
                    
         New-UDRow {
            New-UDColumn -Size 12 {
                New-UDLayout -Columns 1 -Content {
                    New-UDHtml -Markup "<div class='center-align black-text'><h3>$($newref.Name)</h3></h3><h5>Game ID: $($newref.'Game ID')
                    </h5></h5><h5>$($newref.'Top Prize Odds')</h5></h5><h5>Listed Any Prize Odds: $($newref.'Any Prize Odds')</h5></h5><h5>
                    True Odds: $($newref.'True Odds')</h5></div>"
                 
                    New-UDTable -Title "Prize Information" -BackgroundColor "#2C3446" -FontColor "#FB667A" -Headers @("Prize", "At Start", "Remain") -Endpoint {
                    $Cache:GridData = $newref.Info | Sort -Property @{Expression={[int][RegEx]::Match($_.Prize, "(?:\d+)").captures.groups[1].value}}  |  Select Prize, 'At Start', Remain
                    $Cache:GridData | Out-UDTableData -Property @("Prize", "At Start", "Remain") }       
                            }                 
                    }
            }

    } #End of UDPage 

#endregion Pages

Start-UDDashboard -Port 1000 -Content {
    New-UDDashboard -Theme $ThemeColor -Title "Lotto Scratch Stats" @NavDashColors -Pages @($HomePage, $Global:DynamicPage, $Global:ScratcherPage) -Footer $Footer 
    }-Name Dashboard3


