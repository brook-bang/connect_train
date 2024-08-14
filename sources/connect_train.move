
/// Module: connect_train
module connect_train::connect_train {

    use std::u64;
    use std::vector;
    use std::vector::remove;
    use sui::balance;
    use sui::balance::Balance;
    use sui::coin;
    use sui::coin::Coin;
    use sui::object;
    use sui::random;
    use sui::random::{Random, new_generator};
    use sui::sui::SUI;
    use sui::transfer;

    public struct Game has key {
        id: UID,
        player: address,
        stake_pool: Balance<SUI>,
        single_stake_amount:u64,
        fee: u64,
        card: vector<u8>,
    }

    public struct Pool has key{
        id: UID,
        balance: Balance<SUI>,
    }

    public fun create(ctx:&mut TxContext){
        let game = Game {
            id: object::new(ctx),
            player: ctx.sender(),
            stake_pool: balance::zero(),
            single_stake_amount:1_000_000_000,
            fee: 100,
            card:vector[],
        };
        transfer::share_object(game);
    }

    public fun place_card(rand: &Random,ctx: &mut TxContext): u64{

        let mut card = vector[
            1,2,3,4,5,6,7,8,9,10,11,12,13,
            14,15,16,17,18,19,20,21,22,23,24,25,26,
            27,28,29,30,31,32,33,34,35,36,37,38,39,
            40,41,42,43,44,45,46,47,48,49,50,51,52,
        ];
        let mut generator = rand.new_generator(ctx); // 创建随机数生成器
        let rand_num = generator.generate_u64_in_range(0, 51);
        vector::remove(&mut card,rand_num);
        rand_num
    }

    public fun connect_card(pool:&mut Pool,game: &mut Game,coin: Coin<SUI>,rand: &Random,ctx: &mut TxContext):vector<u8>{

        assert!(coin.value() > 1_000_000_000,1);

        coin::put(&mut pool.balance,coin);

        let num = place_card(rand,ctx);
        vector::push_back(&mut game.card, (num as u8));//e
        game.card
    }

    public fun find_same(game: &Game){
        let len = game.card.length();
        let last_card = vector::borrow(&game.card,len - 1);
        let mut i = 0 ;
        if(i < len ){



            

            i + 1;
        }


    }






}

