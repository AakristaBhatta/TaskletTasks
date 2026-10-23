codeunit 90002 "My MOB Receive Display"
{
    // Receive order list: show PO no., expected receipt date and assigned user on each receipt.
    // Receive order lines: show the item reference matching the scanned GS1 GTIN.

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Receive", 'OnGetReceiveOrders_OnAfterSetFromWarehouseReceiptHeader', '', true, true)]
    local procedure OnGetReceiveOrders_OnAfterSetFromWarehouseReceiptHeader(_WhseReceiptHeader: Record "Warehouse Receipt Header"; var _BaseOrderElement: Record "MOB NS BaseDataModel Element")
    var
        WhseReceiptLine: Record "Warehouse Receipt Line";
        PONoTxt: Text;
        ExpectedDateTxt: Text;
    begin
        WhseReceiptLine.SetRange("No.", _WhseReceiptHeader."No.");
        if WhseReceiptLine.FindFirst() then begin
            PONoTxt := WhseReceiptLine."Source No.";
            ExpectedDateTxt := Format(WhseReceiptLine."Due Date");
        end;

        // Display line 1 stays as Tasklet's default (receipt no.)
        _BaseOrderElement.Set_DisplayLine2('PO No.: ' + PONoTxt);
        _BaseOrderElement.Set_DisplayLine3('Expected: ' + ExpectedDateTxt);
        _BaseOrderElement.Set_DisplayLine4('Assigned: ' + _WhseReceiptHeader."Assigned User ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Receive", 'OnGetReceiveOrderLines_OnAfterSetFromWarehouseReceiptLine', '', true, true)]
    local procedure OnGetReceiveOrderLines_OnAfterSetFromWarehouseReceiptLine(_WhseReceiptLine: Record "Warehouse Receipt Line"; var _BaseOrderLineElement: Record "MOB NS BaseDataModel Element")
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.SetRange("Item No.", _WhseReceiptLine."Item No.");
        ItemReference.SetRange("Variant Code", _WhseReceiptLine."Variant Code");
        ItemReference.SetRange("Unit of Measure", _WhseReceiptLine."Unit of Measure Code");
        ItemReference.SetFilter("Reference Type", '%1|%2', ItemReference."Reference Type"::"Bar Code", ItemReference."Reference Type"::Vendor);
        if ItemReference.FindFirst() then
            _BaseOrderLineElement.Set_DisplayLine4('Item Ref.: ' + ItemReference."Reference No.");
    end;
}
