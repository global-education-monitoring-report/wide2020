program define widetests
    args data_path 

    use "`data_path'", clear 
    tosql, table(wide)
    odbc load, table("wide") dsn("WIDE")


end
