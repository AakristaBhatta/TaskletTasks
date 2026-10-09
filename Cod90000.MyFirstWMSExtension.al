codeunit 90000 "My First WMS Extension"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Adhoc Registr.", OnGetRegistrationConfiguration_OnBeforeAddSteps, '', false, false)]
    local procedure SayHelloOnUnplannedMove_OnGetRegistrationConfiguration_OnBeforeAddSteps(_RegistrationType: Text)
    var
        MobWmsToolbox: Codeunit "MOB WMS Toolbox";
    begin
        if _RegistrationType <> MobWmsToolbox."CONST::UnplannedMove"() then // The event fires for EVERY unplanned/adhoc function — guard to target just one.
            exit;
        Error('Hello from my first Mobile WMS extension!');
    end;
}