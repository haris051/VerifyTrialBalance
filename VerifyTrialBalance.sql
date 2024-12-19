drop procedure if Exists PROC_VERIFY_TRIAL_BALANCE;
DELIMITER $$

CREATE PROCEDURE `PROC_VERIFY_TRIAL_BALANCE`(P_COMPANY_ID INT)
BEGIN 

select 
		IFNULL(K.TD,0) as TotalDebit,
		IFNULL(K.TC,0) as TotalCredit,
		IFNULL(K.TD,0)-IFNULL(K.TC,0) as Diff,
		K.Company_Id,
		K.FORM_FLAG,
		K.FORM_ID,
		K.FORMS
	from( 
		
		
		select 
				SUM(I.DebitBalance) as TD,
				SUM(I.CreditBalance) as TC,
				I.Company_Id,
				I.FORM_ID,
				I.FORM_FLAG,
				I.FORMS
			from (
					select 
							case 
								when H.Account_Id = 3 OR H.Account_Id = 2 OR H.Account_Id = 5
								then IFNULL(H.Debit,0)-IFNULL(H.Credit,0)
							end as DebitBalance,
							case 
								when H.Account_Id = 1 OR H.Account_Id = 4 OR H.Account_Id = 6
								then IFNULL(H.Credit,0)-IFNULL(H.Debit,0)
							END 
					as CreditBalance,
					   H.Account_id as Account_type,
					   H.GL_ACC_ID,
					   H.Company_Id,
					   H.FORM_ID,
					   H.Form_Flag,
					   H.FORMS
							from (
			                         select A.FORM_ID,
									        A.FORM_DETAIL_ID,
                                            case when 
													A.glFlag = 511 OR A.glFlag = 15 OR A.glFlag = 512 OR A.glFlag= 20 OR
													A.glFlag = 31 OR A.glFlag = 34 OR A.glFlag = 38 OR A.glFlag = 40  OR 
													A.glFlag = 42 OR A.glFlag = 44 OR A.glFlag = 79 OR A.glFlag =80  OR 
													A.glFlag = 81 OR A.glFlag = 46 OR A.glFlag = 47 OR A.glFlag =50 OR 
													A.glFlag = 51 OR A.glFlag = 54 OR A.glFlag = 56 OR A.glFlag = 86 OR 
													A.glFlag = 87 OR A.glFlag = 85 OR A.glFlag = 58 OR A.glFlag = 60 OR 
													A.glFlag = 150 OR A.glFlag = 151 OR A.glFlag = 62 OR A.glFlag = 65 OR 
													A.glFlag = 68 OR A.glFlag = 70 OR A.glFlag = 72 OR A.glFlag = 73 OR 
													A.glFlag = 76 OR A.glFlag = 78 OR A.glFlag = 77 OR A.glFlag = 101 OR 
													A.glFlag = 23 OR A.glFlag = 102 OR A.glFlag = 104 OR A.glFlag = 106 OR
													A.glFlag = 5554 OR A.glFlag = 29 OR A.glFlag = 28 OR A.glFlag = 108 OR 
													A.glFlag = 109 OR A.glFlag = 111 OR A.glFlag = 114 OR A.glFlag = 5552 OR 
													A.glFlag = 115 OR A.glFlag = 90 OR glFLAG = 5557 OR A.glFlag = 5558
												then A.Amount
											end as Credit,
											case when
													A.glFlag = 510 OR A.glFlag = 16 OR A.glFlag = 513 OR A.glFlag = 19 OR 
													A.glFlag = 32 OR A.glFlag =33 OR A.glFlag = 37 OR A.glFlag =39 OR 
													A.glFlag =41 OR A.glFlag =43 OR A.glFlag =45 OR A.glFlag =48 OR 
													A.glFlag =82 OR A.glFlag =83 OR A.glFlag =84 OR A.glFlag = 49 OR 
													A.glFlag = 52 OR A.glFlag = 100 OR A.glFlag =53 OR A.glFlag = 55 OR 
													A.glFlag = 57 OR A.glFlag = 59 OR A.glFlag = 64 OR A.glFlag = 66 OR 
													A.glFlag = 67 OR A.glFlag = 69 OR A.glFlag = 71 OR A.glFlag = 74 OR 
													A.glFlag = 75 OR A.glFlag = 26 OR A.glFlag = 201 OR A.glFlag = 203 OR 
													A.glFlag = 103 OR A.glFlag = 105 OR A.glFlag = 5553 OR A.glFlag = 107 OR 
													A.glFlag = 204 OR A.glFlag = 205 OR A.glFlag = 110 OR A.glFlag = 113 OR 
													A.glFlag = 112 OR A.glFlag = 5551 OR A.glFlag = 89 OR A.glFlag =116 OR 
													A.glFlag = 117  OR A.glFlag = 5556 OR A.glFlag = 5559
												then A.Amount
											end as Debit,
											A.Company_Id,
											F.Account_Id,
											A.GL_ACC_ID,
											A.Form_Flag,
											A.FORMS
									from(

											select 
												   A.Form_Id,
												   A.Form_Detail_Id,
												   A.GL_FLAG as glFlag,
												   A.Company_Id,
												   A.Amount,
												   A.GL_ACC_ID,
												   A.Form_Flag,
												   case 
														when A.FORM_FLAG = 'StockIN' 
													   		 then B.SN_ID 
														when A.FORM_FLAG = 'StockTransfer' 
															 then C.ST_ID 
													end as Forms												   
											from 	
												   Stock_Accounting A 
												   LEFT JOIN Stock_IN B 
												   ON (A.Form_ID = B.id and A.FORM_FLAG = 'StockIn')  
												   LEFT Join Stock_Transfer C 
												   ON (A.FORM_ID=C.ID and A.FORM_FLAG = 'StockTransfer') 
											where 
												   A.Company_ID = P_COMPANY_ID

											Union All 

											select 
													A.Form_Id,
													A.Form_Detail_Id,
													A.GL_FLAG as glFlag,
													A.Company_Id,
													A.Amount,
													A.GL_ACC_ID,
													A.Form_Flag,
												    case 
														when A.FORM_FLAG = 'VendorCreditMemo'
														     then B.VCM_ID
														when A.FORM_FLAG = 'PartialCredit'
															 then C.PC_ID
														when A.FORM_FLAG = 'ReceiveOrder'
															 then D.RO_ID
													END as FORMS
															
											from 
													Purchase_Accounting A 
											        LEFT JOIN Vendor_Credit_Memo B 
													ON (A.FORM_ID = B.id and A.FORM_FLAG = 'VendorCreditMemo')
													LEFT JOIN Partial_Credit C 
													ON (A.FORM_ID = C.id and A.FORM_FLAG = 'PartialCredit')
													LEFT JOIN Receive_Order D 
													ON (A.Form_ID = D.id and A.FORM_FLAG = 'ReceiveOrder')
											where 
													A.Company_ID = P_COMPANY_ID

											Union All 

											select 
													A.Form_Id,
													A.Form_Detail_Id,
													A.GL_FLAG as glFlag,
													A.Company_Id,
													A.Amount,
													A.GL_ACC_ID,
													A.Form_Flag,
                                                    case 
														 when A.FORM_FLAG ='Saleinvoice'
														      then B.SI_ID
														 when A.FORM_FLAG = 'Salereturn'
														      then C.SR_ID
														 when A.FORM_FLAG = 'Replacement'
														      then D.REP_ID
													END as FORMS
											from 
													Sales_Accounting A 
													LEFT JOIN Sale_Invoice B 
													ON (A.FORM_ID = B.ID and A.FORM_FLAG = 'Saleinvoice')
													LEFT JOIN Sale_Return C 
													ON (A.FORM_ID = C.ID and A.FORM_FLAG = 'Salereturn')
													LEFT JOIN Replacement D 
													ON (A.FORM_ID = D.ID and A.FORM_FLAG = 'Replacement')
											where 
													A.Company_ID = P_COMPANY_ID

											Union All 

											select 
													A.Form_Id,
													A.Form_Detail_Id,
													A.GL_FLAG as glFlag,
													A.Company_Id,
													A.Amount,
													A.GL_ACC_ID,
													A.Form_Flag,
													case 
														when A.FORM_FLAG = 'RepairIn'
															 then B.RN_ID
														when A.FORM_FLAG = 'RepairOut'
														     then C.RE_ID
													END as FORMS
											from 
													Repair_Accounting A 
													LEFT join Repair_IN B 
													ON(A.FORM_ID = B.ID and A.FORM_FLAG = 'RepairIn')
													LEFT join Repair_Out C 
													ON(A.FORM_ID = C.id and A.FORM_FLAG = 'RepairOut')
											where 
													A.Company_ID = P_COMPANY_ID

											Union All 

											select 
													A.Form_Id,
													A.Form_Detail_Id,
													A.GL_FLAG as glFlag,
													A.Company_Id,
													A.Amount,
													A.GL_ACC_ID,
													A.Form_Flag,
													case 
														 when A.FORM_FLAG = 'Adjustment'
															  then B.AJ_ID 
														 when A.FORM_FLAG = 'GeneralJournal'
															  then C.GJ_ID 
													END as FORMS 
											from 
													Adjustment_Accounting A 
													LEFT JOIN Adjustment B 
													ON (A.FORM_ID = B.ID and A.FORM_FLAG = 'Adjustment')
													LEFT JOIN General_Journal C 
													ON (A.FORM_ID = C.ID and A.FORM_FLAG = 'GeneralJournal')
											where 
													A.Company_ID = P_COMPANY_ID

											Union All 

											select 
													A.Form_Id,
													A.Form_Detail_Id,
													A.GL_FLAG as glFlag,
													A.Company_Id,
													A.Amount,
													A.GL_ACC_ID,
													A.Form_Flag,
													case 
													     when A.FORM_FLAG = 'PaymentSent'
															  then B.PAYMENT_SENT_ID
														 when A.FORM_FLAG = 'ReceiveMoney'
															  then C.RECEIVE_MONEY_ID
														 when A.FORM_FLAG = 'Payments' 
														      then D.P_ID 
														 when A.FORM_FLAG = 'Receipts'
														      then E.R_ID 
														 when A.FORM_FLAG = 'Charges'
														      then F.C_ID
												    end as FORMS		  
											from 
													Payments_Accounting A 
													LEFT Join Payment_Sent B 
													ON (A.FORM_ID = B.ID and A.FORM_FLAG = 'PaymentSent')
													LEFT JOIN Receive_Money C 
													ON (A.FORM_ID = C.ID and A.FORM_FLAG = 'ReceiveMoney')
													LEFT JOIN Payments D
													ON (A.FORM_ID = D.Id and A.FORM_FLAG = 'Payments')
													LEFT JOIN Receipts E 
													ON (A.FORM_ID = E.ID and A.FORM_FLAG = 'Receipts')
													LEFT JOIN Charges F 
													ON (A.FORM_ID = F.ID and A.FORM_FLAG = 'Charges')
											where 
													A.Company_ID = P_COMPANY_ID

										)A

								inner join 
										   Accounts_Id E
										ON E.id = A.GL_ACC_ID

								inner join 
										   Account_Type F 
										ON F.id = E.Account_Type_ID


								)H 
								
				)I group by I.Company_Id,I.FORM_FLAG,I.FORM_ID,I.FORMS
		) as K 
				where ABS(IFNULL(K.TD,0)- IFNULL(K.TC,0)) <> 0;
				
END $$
DELIMITER ;