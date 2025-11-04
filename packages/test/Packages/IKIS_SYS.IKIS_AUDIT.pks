/* Formatted on 8/12/2025 6:09:59 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.IKIS_AUDIT
IS
    -- Author  : VANO
    -- Created : 29.07.2013 13:14:57
    -- Purpose : Фукнції аудиту для прикладних підсистем
    -- !!!! НЕ ДЕЛАТЬ ССЫЛОК НА IKIS_AUDIT_PROCESS !!!!

    PROCEDURE WriteMsg (p_msg_type     VARCHAR2,       --Код типу повідомлення
                        p_msg_text     VARCHAR2,          --Текст повідомлення
                        p_msg_ess_id   NUMBER:= 0 --ІД суттєвості, за необхідності
                                                 );
END IKIS_AUDIT;
/


GRANT EXECUTE ON IKIS_SYS.IKIS_AUDIT TO II01RC_IKIS_COMMON
/

GRANT EXECUTE ON IKIS_SYS.IKIS_AUDIT TO IKIS_RBM
/

GRANT EXECUTE ON IKIS_SYS.IKIS_AUDIT TO IKIS_SYSWEB
/

GRANT EXECUTE ON IKIS_SYS.IKIS_AUDIT TO USS_CEA
/

GRANT EXECUTE ON IKIS_SYS.IKIS_AUDIT TO USS_DOC
/

GRANT EXECUTE ON IKIS_SYS.IKIS_AUDIT TO USS_ESR
/

GRANT EXECUTE ON IKIS_SYS.IKIS_AUDIT TO USS_EXCH
/

GRANT EXECUTE ON IKIS_SYS.IKIS_AUDIT TO USS_NDI
/

GRANT EXECUTE ON IKIS_SYS.IKIS_AUDIT TO USS_PERSON
/

GRANT EXECUTE ON IKIS_SYS.IKIS_AUDIT TO USS_RNSP
/

GRANT EXECUTE ON IKIS_SYS.IKIS_AUDIT TO USS_RPT
/

GRANT EXECUTE ON IKIS_SYS.IKIS_AUDIT TO USS_VISIT
/


/* Formatted on 8/12/2025 6:10:01 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY IKIS_SYS.IKIS_AUDIT
IS
    g_save_mode   INTEGER := 2; --1=Через очереди и XML;2=через таблицу, шедулер и DBLINK.

    PROCEDURE WriteMsg (p_msg_type     VARCHAR2,
                        p_msg_text     VARCHAR2,
                        p_msg_ess_id   NUMBER:= 0)
    IS
    BEGIN
        IF p_msg_type IS NULL
        THEN
            raise_application_error (
                -20000,
                'Код сообщения обязателен. Нужно завести соответсвующий код в таблицу IKIS_AUD_OPER и передавать в эту функцию!');
        END IF;

        IF g_save_mode = 1
        THEN
            IKIS_AUD_UTL.Put (IKIS_AUD_UTL.MakeMessage (p_msg_type,
                                                        SYSDATE,
                                                        p_msg_text,
                                                        p_msg_ess_id),
                              'AUTO');
        ELSIF g_save_mode = 2
        THEN
            IKIS_AUD_UTL.PutEX (IKIS_AUD_UTL.MakeMessageEX (p_msg_type,
                                                            SYSDATE,
                                                            p_msg_text,
                                                            p_msg_ess_id),
                                'AUTO');
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            raise_application_error (
                -20000,
                   'IKIS_AUDIT.WriteMsg:'
                || CHR (10)
                || REPLACE (
                          DBMS_UTILITY.FORMAT_ERROR_STACK
                       || ' => '
                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       'ORA-20000:')
                || CHR (10)
                || SQLERRM);
    END;
END IKIS_AUDIT;
/