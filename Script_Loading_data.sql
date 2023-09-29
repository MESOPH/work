create or replace procedure loadDate
is
BEGIN
    INSERT INTO SUPPLIER(
							SUPP_REF			, 			 
							SUPPLIER_NAME 		, 
							SUPP_CONTACT_NAME 	, 
							SUPP_ADDRESS 		, 
							SUPP_CONTACT_NUMBER , 
							SUPP_EMAIL 			 
						)
	SELECT         		    MGT.ORDER_REF           , 			 
							MGT.SUPPLIER_NAME 		, 
							MGT.SUPP_CONTACT_NAME 	, 
							MGT.SUPP_ADDRESS 		, 
							MGT.SUPP_CONTACT_NUMBER , 
							MGT.SUPP_EMAIL 			 
	        
	FROM XXBCM_ORDER_MGT MGT

    WHERE MGT.ORDER_REF = SUBSTR(MGT.ORDER_REF, 1, 5);
	
	IF SQL%ROWCOUNT = 0 THEN
    RAISE NO_DATA_FOUND;
    END IF;
    DBMS_OUTPUT.put_line('SUPPLIER DATA LOADED SUCCESSFULLY');
	COMMIT;
	
	INSERT INTO ORDERS(
						ORDER_REF 			, 
						ORDER_DATE 			,  
						ORDER_TOTAL_AMOUNT 	, 
						ORDER_DESCRIPTION 	, 
						ORDER_STATUS 		, 
						ORDER_LINE_AMOUNT 	  			
						)
	SELECT  			MGT.ORDER_REF 			, 
						MGT.ORDER_DATE 			,  
						MGT.ORDER_TOTAL_AMOUNT 	, --REPLACE(MGT.ORDER_TOTAL_AMOUNT, ',', '')
						MGT.ORDER_DESCRIPTION 	, 
						MGT.ORDER_STATUS 		, 
						MGT.ORDER_LINE_AMOUNT 	  
	        
	FROM XXBCM_ORDER_MGT MGT;
	
	IF SQL%ROWCOUNT = 0 THEN
    RAISE NO_DATA_FOUND;
    END IF;
    DBMS_OUTPUT.put_line('ORDERS DATA LOADED SUCCESSFULLY');
	COMMIT;
	
	INSERT INTO INVOICE(
			
							ORDER_REF 		    , 
							INVOICE_REFERENCE 	, 
							INVOICE_DATE 		, 
							INVOICE_STATUS 		, 
							INVOICE_HOLD_REASON , 
							INVOICE_AMOUNT 		, 
							INVOICE_DESCRIPTION 
						)
	SELECT  				
							MGT.ORDER_REF 		    , 
							MGT.INVOICE_REFERENCE 	, 
							MGT.INVOICE_DATE 		, 
							MGT.INVOICE_STATUS 		, 
							MGT.INVOICE_HOLD_REASON , `
							MGT.INVOICE_AMOUNT 		, --REPLACE(REPLACE(REPLACE( REPLACE(I.INVOICE_AMOUNT, 'o', '0') ,'S','5'),'I','1'),',','')
							MGT.INVOICE_DESCRIPTION  
			
	FROM XXBCM_ORDER_MGT MGT;
	
    IF SQL%ROWCOUNT = 0 THEN
    RAISE NO_DATA_FOUND;
    END IF;
    DBMS_OUTPUT.put_line('DATA LOADED SUCCESSFULLY');
    COMMIT;
	
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.put_line('NO_DATA_FOUND RAISED');
    DBMS_OUTPUT.PUT_LINE ('lOADING FAILS');
END loadDate;
/
begin
    loadDate;
end;