/* Formatted on 8/12/2025 6:00:10 PM (QP5 v5.417) */
CREATE OR REPLACE FUNCTION USS_VISIT.Clear_Name (p_Name IN VARCHAR2)
    RETURN VARCHAR2
IS
BEGIN
    RETURN REGEXP_REPLACE (
               TRIM (
                   TRANSLATE (UPPER (p_Name),
                              'ETIOPAHKXCBM▓',
                              'ер╡нпюмйуябл''')),
               '[^╗ижсйемцьыгузтшбюопнкдфщъвялхрэач╞╡╙╔'' -]');
END;
/
