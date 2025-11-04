/* Formatted on 8/12/2025 6:10:09 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_SYS.audit_callback (
    context    RAW,
    reginfo    SYS.AQ$_REG_INFO,
    descr      SYS.AQ$_DESCRIPTOR,
    payload    RAW,
    payloadl   NUMBER)
AS
    r_dequeue_options      SYS.DBMS_AQ.DEQUEUE_OPTIONS_T;
    r_message_properties   SYS.DBMS_AQ.MESSAGE_PROPERTIES_T;
    v_message_handle       RAW (16);
    o_payload              t_audit_message;
BEGIN
    r_dequeue_options.msgid := descr.msg_id;
    r_dequeue_options.consumer_name := descr.consumer_name;

    DBMS_AQ.DEQUEUE (queue_name           => descr.queue_name,
                     dequeue_options      => r_dequeue_options,
                     message_properties   => r_message_properties,
                     payload              => o_payload,
                     msgid                => v_message_handle);

    IKIS_AUD_PROCESS.ProcessTransitMsg (o_payload);
    COMMIT;
END;
/


GRANT EXECUTE ON IKIS_SYS.AUDIT_CALLBACK TO IKIS_AUD_LNK
/
