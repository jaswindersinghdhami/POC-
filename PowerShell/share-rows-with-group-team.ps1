<#
This function grants read access to team to the workflow.
Testable outside of agent
#>
function Grant-AccessToWorkflow {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$teamName,
        [Parameter(Mandatory)] [String]$workflowId
    )
    Write-Host "teamName - $teamName"
    Write-Host "workflowId - $workflowId"
    $teamId = Get-TeamId $token $dataverseHost $teamName
    Write-Host "teamId - $teamId"
    if($teamId -ne '') {
        $body = "{
        `n    `"Target`":{
        `n        `"workflowid`":`"$workflowId`",
        `n        `"@odata.type`": `"Microsoft.Dynamics.CRM.workflow`"
        `n    },
        `n    `"PrincipalAccess`":{
        `n        `"Principal`":{
        `n            `"teamid`": `"$teamId`",
        `n            `"@odata.type`": `"Microsoft.Dynamics.CRM.team`"
        `n        },
        `n        `"AccessMask`": `"ReadAccess`"
        `n    }
        `n}"
    
        $requestUrlRemainder = "GrantAccess"
        Invoke-DataverseHttpPost $token $dataverseHost $requestUrlRemainder $body
    }
}

<#
This function grants read access to team to the connector.
#>
function Grant-AccessToConnector {
    param (
        [Parameter()] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$teamName,
        [Parameter(Mandatory)] [String]$connectorId
    )
    $teamId = Get-TeamId $token $dataverseHost $teamName
    if($teamId -ne '') {
        $body = "{
        `n    `"Target`":{
        `n        `"connectorid`":`"$connectorId`",
        `n        `"@odata.type`": `"Microsoft.Dynamics.CRM.connector`"
        `n    },
        `n    `"PrincipalAccess`":{
        `n        `"Principal`":{
        `n            `"teamid`": `"$teamId`",
        `n            `"@odata.type`": `"Microsoft.Dynamics.CRM.team`"
        `n        },
        `n        `"AccessMask`": `"ReadAccess`"
        `n    }
        `n}"
    
        $requestUrlRemainder = "GrantAccess"
        Invoke-DataverseHttpPost $token $dataverseHost $requestUrlRemainder $body
    }
}

<#
This function fetches the team guid from the team name.
#>
function Get-TeamId {
    param (
        [Parameter(Mandatory)] [String]$token,
        [Parameter(Mandatory)] [String]$dataverseHost,
        [Parameter(Mandatory)] [String]$teamName
    )
    $teamId = ''
    $odataQuery = 'teams?$filter=name eq ' + "'$teamName'" + '&$select=teamid'
    $response = Invoke-DataverseHttpGet $token $dataverseHost $odataQuery
    if($response.value.length -gt 0) {
        $teamId = $response.value[0].teamid
    }
    return $teamId
}