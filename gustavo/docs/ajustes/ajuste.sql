--AR_ADJUST_PUB.CREATE_ADJUSTMENT.
select art.name
from apps.ar_receivables_trx_all@ebsunifor art
where art.created_by <> -1
and art.status = 'A';