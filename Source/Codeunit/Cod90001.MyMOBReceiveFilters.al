codeunit 90001 "My MOB Receive Filters"
{
    // Adds two optional filters to the Mobile WMS Receive order list.
    // Pattern copied from Tasklet's "MOBWMS ReceiveExt" example (TaskletWMS/Customization).

    // 1) Add the filter fields to the Receive filter screen
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Reference Data", 'OnGetReferenceData_OnAddHeaderConfigurations', '', true, true)]
    local procedure OnGetReferenceData_OnAddHeaderConfigurations(var _HeaderFields: Record "MOB HeaderField Element")
    begin
        _HeaderFields.InitConfigurationKey('ReceiveOrderFilters');

        // Ids must be unique within this configuration key (Tasklet's example uses 50)
        _HeaderFields.Create_ListField(51, 'MyZoneCode');
        _HeaderFields.Set_label('Zone Code');
        _HeaderFields.Set_listValues(GetZoneCodeList());
        _HeaderFields.Set_listSeparator(';');
        _HeaderFields.Set_optional(true);

        _HeaderFields.Create_ListField(52, 'MyAssignedUser');
        _HeaderFields.Set_label('Assigned User');
        _HeaderFields.Set_listValues(GetAssignedUserList());
        _HeaderFields.Set_listSeparator(';');
        _HeaderFields.Set_optional(true);
    end;

    // 2) Apply the filters when the order list is fetched
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Receive", 'OnGetReceiveOrders_OnSetFilterWarehouseReceipt', '', true, true)]
    local procedure OnGetReceiveOrders_OnSetFilterWarehouseReceipt(_HeaderFilter: Record "MOB NS Request Element"; var _WhseReceiptHeader: Record "Warehouse Receipt Header"; var _WhseReceiptLine: Record "Warehouse Receipt Line"; var _IsHandled: Boolean)
    begin
        case _HeaderFilter.Name of
            'MyZoneCode':
                begin
                    if DelChr(_HeaderFilter.Value, '<>', ' ') <> '' then
                        _WhseReceiptLine.SetRange("Zone Code", _HeaderFilter.Value);
                    _IsHandled := true;
                end;
            'MyAssignedUser':
                begin
                    if DelChr(_HeaderFilter.Value, '<>', ' ') <> '' then
                        _WhseReceiptHeader.SetRange("Assigned User ID", _HeaderFilter.Value);
                    _IsHandled := true;
                end;
        end;
    end;

    local procedure GetZoneCodeList() ReturnList: Text
    var
        Zone: Record Zone;
    begin
        ReturnList := ' ';  // blank entry = no filter
        if Zone.FindSet() then
            repeat
                if StrPos(';' + ReturnList + ';', ';' + Zone.Code + ';') = 0 then
                    ReturnList += ';' + Zone.Code;
            until Zone.Next() = 0;
    end;

    local procedure GetAssignedUserList() ReturnList: Text
    var
        UserSetup: Record "User Setup";
    begin
        ReturnList := ' ';  // blank entry = no filter
        if UserSetup.FindSet() then
            repeat
                ReturnList += ';' + UserSetup."User ID";
            until UserSetup.Next() = 0;
    end;
}