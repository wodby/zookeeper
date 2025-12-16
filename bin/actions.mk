.PHONY: check-ready check-live stat

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Required parameter is missing: $1$(if $2, ($2))))

host ?= localhost
max_try ?= 1
wait_seconds ?= 3
delay_seconds ?= 2

command ?= echo "ruok" | nc -w 2 $(host) 2181 | grep -q "imok"
service = ZooKeeper

check-ready:
	wait_for "$(command)" $(service) $(host) $(max_try) $(wait_seconds) $(delay_seconds)

stat:
	echo "stat" | nc -w 2 $(host) 2181

check-live:
	@echo "OK"
