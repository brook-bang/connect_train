
#[test_only]
module connect_train::connect_train_tests {
    // uncomment this line to import the module
    // use connect_train::connect_train;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_connect_train() {
        // pass
    }

    #[test, expected_failure(abort_code = ::connect_train::connect_train_tests::ENotImplemented)]
    fun test_connect_train_fail() {
        abort ENotImplemented
    }
}
