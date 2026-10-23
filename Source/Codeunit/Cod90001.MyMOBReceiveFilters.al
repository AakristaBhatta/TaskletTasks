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

        // Text filter on the purchase order's external reference (see ExternalDocNoFieldNote below)
        _HeaderFields.Create_TextField(53, 'MyExternalDocNo', 'External Document No.', '', 35);
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
            'MyExternalDocNo':
                begin
                    if DelChr(_HeaderFilter.Value, '<>', ' ') <> '' then
                        SetSourceNoFilterFromExternalDocNo(_HeaderFilter.Value, _WhseReceiptLine);
                    _IsHandled := true;
                end;
        end;
    end;

    // ExternalDocNoFieldNote: purchase orders have no "External Document No."; the vendor's own order
    // reference lives in "Vendor Order No.". Change the field below if the business uses another one.
    local procedure SetSourceNoFilterFromExternalDocNo(_ExternalDocNo: Text; var _WhseReceiptLine: Record "Warehouse Receipt Line")
    var
        PurchHeader: Record "Purchase Header";
        SourceNoFilter: Text;
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetFilter("Vendor Order No.", '@*' + _ExternalDocNo + '*');
        if PurchHeader.FindSet() then
            repeat
                if SourceNoFilter <> '' then
                    SourceNoFilter += '|';
                SourceNoFilter += PurchHeader."No.";
            until PurchHeader.Next() = 0;

        _WhseReceiptLine.SetRange("Source Type", Database::"Purchase Line");
        if SourceNoFilter = '' then
            _WhseReceiptLine.SetRange("Source No.", '<none>') // nothing matches: show no receipts
        else
            _WhseReceiptLine.SetFilter("Source No.", SourceNoFilter);
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