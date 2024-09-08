//This is where the Azure resource will be deployed
param location string = 'East US'

//There are parameters/customization of my VPN gateway, my vnet name, address space, and the name of my subnet
//Define these parameters allowing me to change these values without modifying the logic of the bicep file
param vpnGatewayName string = 'myVpnGateway'
param vnetName string = 'myVnet'
param addressSpace string = '10.0.0.0/16'
param gatewaySubnetName string = 'GatewaySubnet'

//This is creating the vnet in Azure using the parameters(values) I have created
//Adress space is using the addresss/CIDR from the variable 
//Then we define the subnet that the VPN will be placed in
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01'= {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    subnets: [
      {
        name: gatewaySubnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

//This creates a dynamic public IP address that the VPN will use, Azure will asign an ip with the VPN is created
//This address will server as the endpoint for all external connections, this will be the address everyone else sees
resource publicIp 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${vpnGatewayName}-publicIP'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}


//This resource type refernces Azure as a resource provider for the resource of networking
resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2020-06-01' = {
  name: vpnGatewayName
  location: location
  properties: {

    //ipConfig represents the config the the VPN network interface
    ipConfigurations: [
      {
        name: 'vpngatewayipconfig'
        properties: {
          //publicAddress links the VPN to the public address above that we get from Azure resource 
          publicIPAddress: {
            id: publicIp.id
          }
          //Links the gateway to the GatewaySubnet
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]

    //Indicating this is a VPN gateway
    gatewayType: 'Vpn'
    
    //This is the type of VPN, a route-based VPN which is more dynamic and flexible
    vpnType: 'RouteBased'
    //Disabling BGP, this is not a complex network
    enableBgp: false
    
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
  }
}
