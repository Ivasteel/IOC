/* Formatted on 8/12/2025 5:55:26 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE USS_NDI.API$DIC_DECODING
IS
    -- Author  : SBOND
    -- Created : 16.08.2022 14:32:13
    -- Purpose : Пакет для перекодувань різних суттєвостей по спеціалізованим алгоритмам

    --функція конвертації району СГ (АСОПД) до району ЄІССС
    FUNCTION District2ComOrgV01 (p_org_src IN NUMBER)
        RETURN NUMBER;
END API$DIC_DECODING;
/


GRANT EXECUTE ON USS_NDI.API$DIC_DECODING TO II01RC_USS_NDI_INTERNAL
/

GRANT EXECUTE ON USS_NDI.API$DIC_DECODING TO IKIS_RBM
/

GRANT EXECUTE ON USS_NDI.API$DIC_DECODING TO USS_ESR
/

GRANT EXECUTE ON USS_NDI.API$DIC_DECODING TO USS_PERSON
/

GRANT EXECUTE ON USS_NDI.API$DIC_DECODING TO USS_RNSP
/

GRANT EXECUTE ON USS_NDI.API$DIC_DECODING TO USS_RPT
/

GRANT EXECUTE ON USS_NDI.API$DIC_DECODING TO USS_VISIT
/


/* Formatted on 8/12/2025 5:55:28 PM (QP5 v5.417) */
CREATE OR REPLACE PACKAGE BODY USS_NDI.API$DIC_DECODING
IS
    -- Author  : SBOND
    -- Created : 16.08.2022 14:32:13
    -- Purpose : Пакет для перекодувань різних суттєвостей по спеціалізованим алгоритмам

    --функція конвертації району СГ (АСОПД) до району ЄІССС
    FUNCTION District2ComOrgV01 (p_org_src IN NUMBER)
        RETURN NUMBER
    IS
        l_lv01               ndi_decoding_config.nddc_code_dest%TYPE;
        l_lv02               ndi_decoding_config.nddc_code_dest%TYPE;
        l_res                NUMBER (14);
        l_cnt                PLS_INTEGER := 0;
        c_tp_l1     CONSTANT VARCHAR2 (10) := 'ORG_DECODE';
        c_src_l1    CONSTANT VARCHAR2 (10) := 'COM';
        c_dest_l1   CONSTANT VARCHAR2 (10) := 'USS';
        c_tp_l2     CONSTANT VARCHAR2 (10) := 'ORG_MIGR';
        c_src_l2    CONSTANT VARCHAR2 (10) := 'SRC';
        c_dest_l2   CONSTANT VARCHAR2 (10) := 'DEST';
    BEGIN
        l_lv01 :=
            NVL (uss_ndi.TOOLS.Decode_Dict (
                     p_Nddc_Tp         => c_tp_l1,
                     p_Nddc_Src        => c_src_l1,
                     p_Nddc_Dest       => c_dest_l1,
                     p_Nddc_Code_Src   => TO_CHAR (p_org_src)),
                 LPAD (p_org_src, 5, '50'));

        IF l_lv01 IS NOT NULL
        THEN
            l_lv02 :=
                uss_ndi.TOOLS.Decode_Dict (p_Nddc_Tp         => c_tp_l2,
                                           p_Nddc_Src        => c_src_l2,
                                           p_Nddc_Dest       => c_dest_l2,
                                           p_Nddc_Code_Src   => l_lv01);
        END IF;

        l_res := TO_NUMBER (NVL (l_lv02, l_lv01));

        SELECT COUNT (*)
          INTO l_cnt
          FROM ikis_sys.v_opfu org
         WHERE org.org_id = l_res;

        IF l_cnt = 1
        THEN
            RETURN l_res;
        END IF;

        RETURN NULL;
    END;
END API$DIC_DECODING;
/