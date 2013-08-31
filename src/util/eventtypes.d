module util.eventtypes;

public import util.event;
public import fuji.types;
public import interfaces.entity;

alias EventTemplate!() VoidEvent;
alias EventTemplate!(MFRect) MFRectEvent;
alias EventTemplate!(IEntity[string]) IEntityMapEvent;
