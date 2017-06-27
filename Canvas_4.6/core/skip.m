function except_level = skip(tm,tn,exception)
    
    except_level = 0;
    N = size(exception)(1);
    for i = 1 : N,
        if (tm>exception(i,1) && tn<exception(i,2))
            except_level = except_level + 1;
        end
    end
