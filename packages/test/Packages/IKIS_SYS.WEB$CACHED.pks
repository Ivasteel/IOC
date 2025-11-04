/* Formatted on 8/12/2025 6:10:00 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE IKIS_SYS.web$cached
IS
    -- Author  : KALEV
    -- Created : 28.12.2010 11:49:33
    -- Purpose : Позначки про сплату

    -- процедура порівняння позначок про сплату на основі вюхи фонду
    PROCEDURE CheckInsurCached;

    -- процедура джоба
    PROCEDURE JobInsurCached;
END web$cached;
/
