class_name DropEntry
extends Resource

## Un tipo di pickup droppato da un Breakable, con i suoi valori.

## La scena del pickup. Il suo nodo root deve estendere BasePickup.
@export var scene: PackedScene

## Quanti pezzi di questo tipo contiene il sasso.
## Tirato una volta sola alla nascita del sasso, non a ogni colpo.
@export var min_amount: int = 1
@export var max_amount: int = 1

## Se questa entry può uscire mentre trivelli, invece che solo alla distruzione.
## È la scelta di design: quando è false nessuna skill può sbloccarla.
@export var drops_while_drilling: bool = false

## Probabilità di un drop fortunato per colpo di trivella a danno base, prima
## delle skill. Con più danno si tira più volte nello stesso colpo, così il
## numero totale di tiri su un sasso dipende dai suoi HP e non dalla build.
## Può stare a 0: con drops_while_drilling acceso, sarà Lucky Drilling ad alzarla.
@export_range(0.0, 1.0) var chance_per_drill_tick: float = 0.0
