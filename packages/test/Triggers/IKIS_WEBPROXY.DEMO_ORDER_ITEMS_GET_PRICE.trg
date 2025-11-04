/* Formatted on 8/12/2025 6:12:49 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_WEBPROXY."DEMO_ORDER_ITEMS_GET_PRICE"
    BEFORE INSERT OR UPDATE
    ON IKIS_WEBPROXY.DEMO_ORDER_ITEMS
    FOR EACH ROW
DECLARE
    l_list_price   NUMBER;
BEGIN
    -- First, we need to get the current list price of the order line item
    SELECT list_price
      INTO l_list_price
      FROM demo_product_info
     WHERE product_id = :new.product_id;

    -- Once we have the correct price, we will update the order line with the correct price
    :new.unit_price := l_list_price;
END;
/
