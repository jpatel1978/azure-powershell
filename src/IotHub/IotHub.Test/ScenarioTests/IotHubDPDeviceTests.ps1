﻿# ----------------------------------------------------------------------------------
#
# Copyright Microsoft Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------


#################################
## IotHub Device Cmdlets	   ##
#################################

<#
.SYNOPSIS
Test all iothub device cmdlets
#>
function Test-AzureRmIotHubDeviceLifecycle
{
	$Location = Get-Location "Microsoft.Devices" "IotHubs"
	$IotHubName = getAssetName
	$ResourceGroupName = getAssetName
	$Sku = "S1"
	$device1 = getAssetName
	$device2 = getAssetName
	$device3 = getAssetName
	$primaryThumbprint = '38303FC7371EC78DDE3E18D732C8414EE50969C7'
	$secondaryThumbprint = 'F54465586FBAF4AC269851424A592254C8861BE7'

	# Create Resource Group
	$resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location 

	# Create Iot Hub
	$iothub = New-AzIotHub -Name $IotHubName -ResourceGroupName $ResourceGroupName -Location $Location -SkuName $Sku -Units 1

	# Get all devices
	$devices = Get-AzIotHubDevice -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName
	Assert-True { $devices.Count -eq 0 }

	# Add iot device with symmetric authentication
	$newDevice1 = Add-AzIotHubDevice -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName -DeviceId $device1 -AuthMethod 'shared_private_key'
	Assert-True { $newDevice1.Id -eq $device1 }
	Assert-True { $newDevice1.Authentication.Type -eq 'Sas' }
	Assert-False { $newDevice1.Capabilities.IotEdge }

	# Add iot device with selfsigned authentication
	$newDevice2 = Add-AzIotHubDevice -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName -DeviceId $device2 -AuthMethod 'x509_thumbprint' -PrimaryThumbprint $primaryThumbprint -SecondaryThumbprint $secondaryThumbprint
	Assert-True { $newDevice2.Id -eq $device2 }
	Assert-True { $newDevice2.Authentication.Type -eq 'SelfSigned' }
	Assert-False { $newDevice2.Capabilities.IotEdge }

	# Add iot device with certifictae authority authentication
	$newDevice3 = Add-AzIotHubDevice -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName -DeviceId $device3 -AuthMethod 'x509_ca'
	Assert-True { $newDevice3.Id -eq $device3 }
	Assert-True { $newDevice3.Authentication.Type -eq 'CertificateAuthority' }
	Assert-False { $newDevice3.Capabilities.IotEdge }

	# Get all devices
	$devices = Get-AzIotHubDevice -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName
	Assert-True { $devices.Count -eq 3}

	# Update Device
	$updatedDevice1 = Set-AzIoTHubDevice -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName -DeviceId $device1 -Status 'Disabled' -StatusReason 'Reason1'
	Assert-True { $updatedDevice1.Id -eq $device1 }
	Assert-True { $updatedDevice1.Status -eq 'Disabled' }
	Assert-True { $updatedDevice1.StatusReason -eq 'Reason1' }

	# Update iot device to edge device
	$updatedDevice2 = Set-AzIoTHubDevice -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName -DeviceId $device3 -EdgeEnabled $true
	Assert-True { $updatedDevice2.Capabilities.IotEdge }

	# Get device detail
	$iotDevice = Get-AzIotHubDevice -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName -DeviceId $device1
	Assert-True { $iotDevice.Id -eq $device1 }
	Assert-True { $iotDevice.Authentication.Type -eq 'Sas' }
	Assert-False { $iotDevice.Capabilities.IotEdge }
	Assert-True { $iotDevice.Status -eq 'Disabled' }
	Assert-True { $iotDevice.StatusReason -eq 'Reason1' }

	# Delete iot device
	$result = Remove-AzIotHubDevice -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName -DeviceId $device1 -Passthru
	Assert-True { $result }

	# Delete all devices
	$result = Remove-AzIotHubDevice -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName -Passthru
	Assert-True { $result }
}