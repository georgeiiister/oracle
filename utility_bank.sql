create or replace package utility_bank is

g_separator_collection constant varchar2(1):=',';

/******************************************************************************
split string by separator to table char
******************************************************************************/
function split2table_char2(
                            p_source_string varchar2, 
                            p_separator varchar2 default g_separator_collection,
                            p_trim_space pls_integer default 1
                           ) return table_char;

/******************************************************************************
split string by separator to table number
*******************************************************************************/
function split2table_number(
                            p_source_string varchar2, 
                            p_separator varchar2 default g_separator_collection,
                            p_raise_exception_when_error_value pls_integer := 1
                           ) return table_number;

/******************************************************************************
split string by separator to table number
*******************************************************************************/
function split2table_date(
                            p_source_string varchar2, 
                            p_separator varchar2 default g_separator_collection,
                            p_date_mask varchar2,
                            p_raise_exception_when_error_value pls_integer := 1
                           ) return table_date;

end utility_bank;
/
create or replace package body utility_bank is

/******************************************************************************
split string by separator to table char
*******************************************************************************/
function split2table_char2(
                            p_source_string varchar2, 
                            p_separator varchar2 default g_separator_collection,
                            p_trim_space pls_integer default 1
                           ) return table_char
is
    ntResult table_char:= table_char();
    iResultSearch integer:= 1;
    iResultPrev integer:= iResultSearch;
    sDummy varchar2(32767):= trim(p_source_string);
    iLength integer:= 0;
begin

     if substr(sDummy, -1, 1)!= p_separator then
         sDummy:= concat(sDummy, p_separator);
     end if;

     loop
         iResultSearch:= instr(sDummy, p_separator, iResultPrev);
         exit when iResultSearch = 0;
         iLength:= iResultSearch - iResultPrev;
         ntResult.extend;
         ntResult(ntResult.last):= substr(sDummy, iResultPrev, iLength);
         if p_trim_space > 0 then
            ntResult(ntResult.last):=trim(ntResult(ntResult.last));
         end if;
         iResultPrev:= iResultSearch + 1;
     end loop;

     return ntResult;
end;

/******************************************************************************
split string by separator to table number
*******************************************************************************/
function split2table_number(
                            p_source_string varchar2, 
                            p_separator varchar2 default g_separator_collection,
                            p_raise_exception_when_error_value pls_integer := 1
                           ) return table_number
is
    ntResult table_number:=table_number();
    ntDummy table_char;
    iDummy  integer; 
begin
   ntDummy:= split2table_char2(
                                 p_source_string => p_source_string,
                                 p_separator => p_separator   
                               );
   if ntDummy.count() > 0 then
       for i in ntDummy.first..ntDummy.last loop
           iDummy:=null;
           begin
             iDummy:= to_number(ntDummy(i));
             ntResult.extend;
             ntResult(ntResult.last):= iDummy;
           exception  
             when others then
                 if p_raise_exception_when_error_value > 0 then
                    raise;
                 end if;
           end;  
       end loop;
   end if;
   return ntResult; 
end;

/******************************************************************************
split string by separator to table date
*******************************************************************************/
function split2table_date(
                            p_source_string varchar2, 
                            p_separator varchar2 default g_separator_collection,
                            p_date_mask varchar2,
                            p_raise_exception_when_error_value pls_integer := 1
                           ) return table_date
is
    ntResult table_date:=table_date();
    ntDummy table_char;
    dtDummy  date;
begin
   ntDummy:= split2table_char2(
                                 p_source_string => p_source_string,
                                 p_separator => p_separator   
                               );
   if ntDummy.count() > 0 then
       for i in ntDummy.first..ntDummy.last loop
           dtDummy:=null;
           begin
             dtDummy:= to_date(ntDummy(i),p_date_mask);
             ntResult.extend;
             ntResult(ntResult.last):= dtDummy;
           exception  
             when others then
                 if p_raise_exception_when_error_value > 0 then
                    raise;
                 end if;
           end;  
       end loop;
   end if;
   return ntResult; 
end;

end utility_bank;
/
