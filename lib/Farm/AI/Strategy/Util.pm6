use Farm::Sim::Posse;

sub inflate-posse-hash(%p) is export {
    hash map -> $k,$v { 
        $k => posse-from-long($v)
    }, %p.kv
} 

