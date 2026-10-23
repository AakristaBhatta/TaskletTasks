codeunit 90003 "My MOB Receive Delivery Note"
{
    // Ask for the vendor delivery note number when posting a warehouse receipt
    // and store it on the receipt so it flows to the posted receipt / purchase receipt.

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Receive", 'OnPostReceiveOrder_OnAddStepsToWarehouseReceiptHeader', '', true, true)]
    local procedure OnPostReceiveOrder_OnAddStepsToWarehouseReceiptHeader(var _OrderValues: Record "MOB Common Element"; _WhseReceiptHeader: Record "Warehouse Receipt Header"; var _StepsElement: Record "MOB Steps Element")
    begin
        _StepsElement.Create_TextStep(
            90010,                                  // Id: unique within this registration
            'MyVendorDeliveryNote',                 // Name: key read back on posting
            'Vendor Delivery Note',                 // Header
            'Delivery note no.',                    // Label
            'Enter the delivery note number from the supplier paperwork', // HelpLabel
            _WhseReceiptHeader."Vendor Shipment No.", // Default value
            35);                                    // Max length ("Vendor Shipment No." is Text[35])
        _StepsElement.Set_optional(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Receive", 'OnPostReceiveOrder_OnBeforePostWarehouseReceipt', '', true, true)]
    local procedure OnPostReceiveOrder_OnBeforePostWarehouseReceipt(var _OrderValues: Record "MOB Common Element"; var _WhseReceiptHeader: Record "Warehouse Receipt Header")
    var
        DeliveryNote: Text;
    begin
        DeliveryNote := _OrderValues.GetValue('MyVendorDeliveryNote');
        if DelChr(DeliveryNote, '<>', ' ') = '' then
            exit;

        _WhseReceiptHeader."Vendor Shipment No." := CopyStr(DeliveryNote, 1, MaxStrLen(_WhseReceiptHeader."Vendor Shipment No."));
        _WhseReceiptHeader.Modify(true);
    end;
}
