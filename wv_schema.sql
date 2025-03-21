create table parties (
    id_party int,
    title_party text
);

create table roles (
    id_role int,
    description_role text
);

create table players (
    id_player int,
    pseudo text
);

create table players_in_parties (
    id_party int,
    id_player int,
    id_role int,
    is_alive text
);

create table turns (
    id_turn int,
    id_party int,
    start_time datetime,
    end_time datetime
);

create table players_play (
    id_player int,
    id_turn int,
    start_time datetime,
    end_time datetime,
    action varchar(10),
    origin_position_col text,
    origin_position_row text,
    target_position_col text,
    target_position_row text
);