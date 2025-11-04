/* Formatted on 8/12/2025 6:06:35 PM (QP5 v5.417) */
CREATE OR REPLACE PROCEDURE IKIS_FINZVIT.SetPayrollSt4Rbm (
    p_pkt_id   IN NUMBER,
    p_pkt_st   IN VARCHAR2)
IS
    l_pr_st   VARCHAR2 (10);
BEGIN
    IF p_pkt_st = 'RCV'
    THEN
        FOR pr_rec IN (SELECT pr.pr_id, pr.pr_rbm_pkt
                         FROM ikis_finzvit.payroll_reestr pr
                        WHERE pr.pr_rbm_pkt = p_pkt_id AND pr.pr_st = 'T')
        LOOP
            UPDATE ikis_finzvit.payroll_reestr pr
               SET pr_st = 'R'
             WHERE pr.pr_id = pr_rec.pr_id AND pr.pr_st = 'T';

            INSERT INTO pr_log (prl_id,
                                prl_pr,
                                prl_pr_st,
                                prl_action,
                                prl_user,
                                prl_dt)
                 VALUES (NULL,
                         pr_rec.pr_id,
                         'R',
                         'RCV',
                         NULL,
                         SYSDATE);
        END LOOP;
    END IF;
EXCEPTION
    WHEN OTHERS
    THEN
        --raise_application_error(-20000, 'Помилка зміни статусу відомості: '||sqlerrm||chr(10)||dbms_utility.format_error_backtrace);
        NULL;
END;
/


GRANT EXECUTE ON IKIS_FINZVIT.SETPAYROLLST4RBM TO IKIS_RBM
/
