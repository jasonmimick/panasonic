Class HSPanasonic.ScanPoint.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="HSPanasonic.ScanPoint.Production" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="EndpointService" Category="" ClassName="EnsLib.HTTP.GenericService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigName">EndpointOperation</Setting>
    <Setting Target="Adapter" Name="Port">8765</Setting>
  </Item>
  <Item Name="EndpointOperation" Category="" ClassName="HSPanasonic.ScanPoint.EndpointOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="SearchSubjectTarget">HSPanasonic.ScanPoint.SearchSubjectSampleOperation</Setting>
    <Setting Target="Host" Name="SubmitDocumentTarget">HSPanasonic.ScanPoint.SubmitDocumentFileOperation</Setting>
  </Item>
<Item Name="HSPanasonic.ScanPoint.SearchSubjectSampleOperation" Category="" ClassName="HSPanasonic.ScanPoint.SearchSubjectSampleOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="HSPanasonic.ScanPoint.SubmitDocumentFileOperation" Category="" ClassName="HSPanasonic.ScanPoint.SubmitDocumentFileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
</Production>
}

}

