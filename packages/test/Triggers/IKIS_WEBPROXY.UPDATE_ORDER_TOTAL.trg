/* Formatted on 8/12/2025 6:12:50 PM (QP5 v5.417) */
CREATE OR REPLACE TRIGGER IKIS_WEBPROXY."UPDATE_ORDER_TOTAL"
    AFTER INSERT OR UPDATE OR DELETE
    ON IKIS_WEBPROXY.DEMO_ORDER_ITEMS
BEGIN
    -- Update the Order Total when any order item is changed

    UPDATE demo_orders
       SET order_total =
               (SELECT SUM (unit_price * quantity)
                  FROM demo_order_items
                 WHERE demo_order_items.order_id = demo_orders.order_id);
END;
/
