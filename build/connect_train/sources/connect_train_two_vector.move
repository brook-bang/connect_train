module connect_train::connect_train_two_vector {

    use std::vector;
    use sui::balance;
    use sui::balance::Balance;
    use sui::coin;
    use sui::coin::{Coin};
    use sui::random;
    use sui::random::Random;
    use sui::sui::SUI;
    use sui::transfer;

    public struct Game has key {
        id: UID,
        playerA: address,
        playerB: address,
        playerA_card: vector<u64>,
        playerB_card: vector<u64>,
        card_pool: vector<u64>,
        stake_pool: vector<Balance<SUI>>,
        single_stake_amount:u64,
        fee: u64,
    }

    public struct Pool has key{
        id: UID,
        balance: Balance<SUI>,
    }

    public entry fun create(playerB: address,rand: &Random,ctx:&mut TxContext){
        let mut full_card = vector[
            1,2,3,4,5,6,7,8,9,10,11,12,13,
            1,2,3,4,5,6,7,8,9,10,11,12,13,
            1,2,3,4,5,6,7,8,9,10,11,12,13,
            1,2,3,4,5,6,7,8,9,10,11,12,13,
        ];
        let mut playB_full_card = vector::empty<u64>();
        let mut i =0u64;
        let mut generator = rand.new_generator(ctx);
        while (i < 26){
            let full_card_len = vector::length(&full_card);
            let rand_card = random::generate_u64_in_range(&mut generator,0,full_card_len-1);
            let single_card = vector::remove(&mut full_card,rand_card);
            vector::push_back(&mut playB_full_card,single_card);
            i = i + 1;
        };

        let game = Game {
            id: object::new(ctx),
            playerA: ctx.sender(),
            playerB,
            playerA_card:full_card,
            playerB_card:playB_full_card,
            card_pool:vector[],
            stake_pool: vector[],
            single_stake_amount:1_000_000_000,
            fee: 100,
        };
        transfer::share_object(game);
    }

    public fun playerA_place_card(game: &mut Game,rand: &Random,ctx: &mut TxContext): u64{

        assert!(ctx.sender() == game.playerA,1);

        let mut card = game.playerA_card;

        let mut generator = rand.new_generator(ctx); // 创建随机数生成器
        let rand_num = generator.generate_u64_in_range(0, 25);
        vector::remove(&mut card,rand_num);
        rand_num
    }

    public fun playerB_place_card(game: &mut Game,rand: &Random,ctx: &mut TxContext): u64{

        assert!(ctx.sender() == game.playerB,1);

        let mut card = game.playerB_card;

        let mut generator = rand.new_generator(ctx); // 创建随机数生成器
        let rand_num = generator.generate_u64_in_range(0, 25);
        vector::remove(&mut card,rand_num);
        rand_num
    }

    public entry fun playerA_play_game(game: &mut Game,coin: Coin<SUI>,rand: &Random,ctx: &mut TxContext){

        assert!(coin.value() > game.single_stake_amount,1);

        let stake = coin::into_balance(coin);

        let num = playerA_place_card(game,rand,ctx);
        vector::push_back(&mut game.stake_pool,stake);

        let (boolean,same_card_index) = vector::index_of(&game.card_pool,&num);
        let mut i = same_card_index;

        if(boolean){
            let mut wincoin_pool = balance::zero<SUI>();
            let len = vector::length(&game.card_pool);
            while (i <= len){
                vector::remove(&mut game.card_pool,i);
                let wincoin = vector::remove(&mut game.stake_pool,i);
                wincoin_pool.join(wincoin);
                i = i + 1;
            };
            let last_stake_pool = vector::length(&game.stake_pool);
            wincoin_pool.join(vector::remove(&mut game.stake_pool,last_stake_pool));
            transfer::public_transfer(coin::from_balance(wincoin_pool,ctx),ctx.sender());
        } else {
            vector::push_back(&mut game.card_pool,num);
        }

    }

    public entry fun playerB_play_game(game: &mut Game,coin: Coin<SUI>,rand: &Random,ctx: &mut TxContext){

        assert!(coin.value() > game.single_stake_amount,1);

        let stake = coin::into_balance(coin);

        let num = playerB_place_card(game,rand,ctx);
        vector::push_back(&mut game.stake_pool,stake);

        let (boolean,same_card_index) = vector::index_of(&game.card_pool,&num);
        let i = same_card_index;

        if(boolean){
            let mut wincoin_pool = balance::zero<SUI>();
            let len = vector::length(&game.card_pool);
            if(i <= len){
                vector::remove(&mut game.card_pool,i);
                let wincoin = vector::remove(&mut game.stake_pool,i);
                wincoin_pool.join(wincoin);
                i + 1;
            };
            let last_stake_pool = vector::length(&game.stake_pool);
            wincoin_pool.join(vector::remove(&mut game.stake_pool,last_stake_pool));
            transfer::public_transfer(coin::from_balance(wincoin_pool,ctx),ctx.sender());
        } else {
            vector::push_back(&mut game.card_pool,num);
        }

    }

    // public fun playerB_play_game(game: &mut Game,coin: Coin<SUI>,rand: &Random,ctx: &mut TxContext){
    //
    //     assert!(coin.value() > game.single_stake_amount,1);
    //
    //     let stake = coin::into_balance(coin);
    //
    //     let num = playerB_place_card(game,rand,ctx);
    //
    //     vector::push_back(&mut game.card_pool,num);
    //     vector::push_back(&mut game.stake_pool,stake);
    //     if(vector::contains(&game.card_pool,&num)){
    //         let same_card = find_same(game);
    //         let mut win_coin_pool = balance::zero<SUI>();
    //         if( same_card < game.card_pool.length() ){
    //             vector::remove(&mut game.card_pool,same_card);
    //             let win_coin = vector::remove(&mut game.stake_pool,same_card);
    //             win_coin_pool.join(win_coin);
    //             same_card + 1;
    //         };
    //     };
    // }
    //
    // public fun win_sum(game: &Game): u64{
    //     let len = game.card_pool.length();
    //     let first = find_same(game);
    //     let win_len = len - 1 - first;
    //     win_len
    // }


}
