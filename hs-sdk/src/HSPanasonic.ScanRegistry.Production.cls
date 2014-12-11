Class HSPanasonic.ScanRegistry.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="HSPanasonic.ScanRegistry.Production" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="ConfiguationOperation" Category="" ClassName="HSPanasonic.ScanRegistry.ConfigurationOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="ConfigurationService" Category="" ClassName="EnsLib.HTTP.GenericService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigName">ConfiguationOperation</Setting>
    <Setting Target="Adapter" Name="Port">20187</Setting>
  </Item>
</Production>
}

}

