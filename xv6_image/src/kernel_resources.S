.data
.global _binary_initcode_start
.global _binary_initcode_end
.global _binary_entryother_start
.global _binary_entryother_end

_binary_initcode_start:
	.incbin "./obj/initcode"
_binary_initcode_end:

_binary_entryother_start:
	.incbin "./obj/entryother"
_binary_entryother_end:

