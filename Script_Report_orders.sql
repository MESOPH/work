
CREATE OR REPLACE PROCEDURE reportorders
IS  
            OrderReference varchar2(100);
			OrderPeriod varchar2(100);
			SupplierName varchar2(100);
			OrderTotalAmount varchar2(100);
			OrderStatus  varchar2(100);
			InvoiceReference varchar2(100);
			InvoiceTotalAmount varchar2(100);
			Actions_S   varchar2(100);
            total_rows number(2); 
  CURSOR C1
  IS 
        SELECT rest.OrderReference OrderRef,
			rest.OrderPeriod ,
			rest.SupplierName ,
			rest.OrderTotalAmount ,
			rest.OrderStatus  ,
			rest.InvoiceReference ,
			rest.InvoiceTotalAmount ,
			rest.Actions
            FROM   
    	    (SELECT 
               rank() over (partition by O.ORDER_REF order by O.ROWID) as myrank,
			   SUBSTR(O.ORDER_REF,4) OrderReference,
			   SUBSTR(TO_CHAR(TO_DATE(O.ORDER_DATE,'DD-MM-YYYY'), 'DD-MON-YYYY'),-8) OrderPeriod,
			   INITCAP(S.SUPPLIER_NAME) SupplierName,
			   TO_CHAR(REPLACE(O.ORDER_TOTAL_AMOUNT, ',', ''),'99G999G999D99') OrderTotalAmount,
			   O.ORDER_STATUS OrderStatus,
			   I.INVOICE_REFERENCE InvoiceReference,
			   TO_CHAR(REPLACE(REPLACE(REPLACE( REPLACE(I.INVOICE_AMOUNT, 'o', '0') ,'S','5'),'I','1'),',','') ,'99G999G999D99') InvoiceTotalAmount, 
			   CASE I.INVOICE_STATUS
					WHEN 'Paid'
					THEN 'OK'
					WHEN 'Pending'
					THEN 'To follow up' 
					ELSE 'To Verify' 			
			   END  Actions
           
		FROM orders O 
        INNER JOIN  invoice I ON O.ORDER_REF = I.ORDER_REF 
		INNER JOIN supplier S ON  SUBSTR(I.ORDER_REF, 1, 5) = S.SUPP_REF
        ) rest
		WHERE 
        rest.myrank =1
        ORDER BY OrderRef DESC;    
BEGIN
  OPEN C1;
  LOOP    
    fetch c1 into OrderReference ,
			OrderPeriod ,
			SupplierName ,
			OrderTotalAmount ,
			OrderStatus  ,
			InvoiceReference ,
			InvoiceTotalAmount ,
			Actions_S   ; 
    EXIT when C1%NOTFOUND;  
     IF C1%found THEN 
      total_rows := C1%rowcount;
      dbms_output.put_line( ' ORDER '||total_rows);
      END IF;   
   
    DBMS_OUTPUT.PUT_LINE( 'OrderReference:'|| OrderReference||' OrderPeriod:'|| OrderPeriod ||' SupplierName:'||SupplierName ||
    ' OrderTotalAmount:'||OrderTotalAmount ||' OrderStatus:'||OrderStatus ||' InvoiceReference:'||InvoiceReference ||
    ' InvoiceTotalAmount:'||InvoiceTotalAmount ||' Actions_S:'||Actions_S);
  END LOOP;
  dbms_output.put_line( total_rows || ' ORDERS IN TOTAL');
  CLOSE C1;
EXCEPTION
	  WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.put_line('NO_DATA_FOUND RAISED');
		DBMS_OUTPUT.PUT_LINE ('lOADING FAILS');
	  WHEN OTHERS THEN 
	  ROLLBACK;
END reportorders;
/
begin
    reportorders;
end;