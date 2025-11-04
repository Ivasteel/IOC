/* Formatted on 8/12/2025 6:12:50 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_WEBPROXY."INSERT_DEMO_ORDER_ITEMS"
    BEFORE INSERT
    ON IKIS_WEBPROXY.DEMO_ORDER_ITEMS
    FOR EACH ROW
BEGIN
    DECLARE
        order_item_id   NUMBER;
    BEGIN
        SELECT demo_order_items_seq.NEXTVAL INTO order_item_id FROM DUAL;

        :new.ORDER_ITEM_ID := order_item_id;
    END;
END;
/
