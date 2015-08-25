require 'rails_helper'

module YorkshirePayments
  RSpec.describe Signature do
    describe '#initialize' do
      context 'with string input' do
        it 'converts fields from raw POST body' do
          s = Signature.new('a=A&b=B%0A', '')
          expect(s.fields).to eq [
            ['a', 'A'],
            ['b', "B\n"]
          ]
        end

        it 'handles empty values' do
          s = Signature.new('cardTypeCode=&cartType=', '')
          expect(s.fields).to eq [
            ['cardTypeCode', ''],
            ['cartType', '']
          ]
        end
      end
    end

    describe '#sign' do
      it 'returns a signature' do
        s = Signature.new(fields_without_signature, pre_shared_key)
        expect(s.sign).to eq signature
      end
    end

    describe '#verify' do
      it 'returns truthy for a correct signature' do
        s = Signature.new(fields_with_signature, pre_shared_key)
        expect(s.verify).to be_truthy
      end

      it 'returns falsey for a bad signature' do
        s = Signature.new(fields_with_bad_signature, pre_shared_key)
        expect(s.verify).to be_falsey
      end

      it 'returns falsey for absent signature' do
        s = Signature.new(fields_without_signature, pre_shared_key)
        expect(s.verify).to be_falsey
      end
    end

    def url_encoded_to_fields(url_encoded)
      url_encoded
        .split('&')
        .map {|a| a.split('=') }
        .map {|a,b| [a, CGI::unescape(b)] }
    end

    let(:pre_shared_key) { 'Engine0Milk12Next' }

    let(:signature) {
      "48aec70c50b51732edce4cd945e930be0c5dfd4d815cad8e6f56a248390a70a0c17e9b786837b9045b9da72fdbfe59f499931825c5b669b36680fafc976dd4f9"
    }

    let(:fields_with_signature) {
      url_encoded_to_fields(url_encoded_with_signature)
    }

    let(:fields_with_bad_signature) {
      url_encoded_to_fields(url_encoded_with_bad_signature)
    }

    let(:fields_without_signature) {
      url_encoded_to_fields(url_encoded_without_signature)
    }

    let(:url_encoded_with_signature) {
      url_encoded_without_signature + "&signature=" + signature
    }

    let(:url_encoded_with_bad_signature) {
      url_encoded_without_signature + "&signature=BAD"
    }

    let(:url_encoded_without_signature) {
      "merchantID=101380&threeDSEnabled=Y&avscv2CheckEnabled=Y&customerID=921&eReceiptsEnabled=N&transactionID=8924172&xref=15073015KD03MY13VL43HTL&state=captured&redirectURL=https%3A%2F%2Fzmey.co.uk%2Fpayments%2Fyorkshire_payments%2Fredirect&callbackURL=https%3A%2F%2Fzmey.co.uk%2Fpayments%2Fyorkshire_payments%2Fcallback&remoteAddress=81.156.111.104&action=SALE&type=1&currencyCode=826&countryCode=826&amount=3739&transactionUnique=20150730-D5RI&cardTypeCode=VC&cardNumberMask=%2A%2A%2A%2A%2A%2A%2A%2A%2A%2A%2A%2A0821&cardExpiryDate=1115&customerName=Ian&customerAddress=Flat+6%0D%0APrimrose+Rise%0D%0A347+Lavender+Road%0D%0ANorthampton&customerPostcode=NN17+8YG&customerPhone=%2B447921308719&customerEmail=ianfleeton%40gmail.com&eReceiptsStoreID=1&cv2CheckPref=matched&addressCheckPref=matched%2Cnot+matched%2Cpartially+matched&postcodeCheckPref=matched&threeDSCheckPref=not+known%2Cnot+checked%2Cauthenticated%2Cnot+authenticated%2Cattempted+authentication&threeDSXID=MDAwMDAwMDAwMDAwMDg5MjQxNzI%3D&threeDSEnrolled=Y&threeDSACSURL=https%3A%2F%2Fdropit.3dsecure.net%3A9443%2FPIT%2FACS&threeDSPaReq=eJxVUttuwjAM%2FZWKD2iahlBAbiSg0sYDqBtI2x6z4tGO9UJSVtjXLyntGA%2BRfI6d%0D%0AE%2Fs4sE0VYrTB5KRQwAq1lnt0sl044Pxd%2Bijp2GMYDATEs2c8CvhGpbOyENT1XB9I%0D%0AD81VlaSyqAXI5DhfrgUP6JgNgXQQclTLSEz4kPsTQ18hFDJH8Vaqg04zhU4sLzkW%0D%0AtXbWZeGwCEibh6Q8FbW6iLE%2FAtIDOKkvkdZ1NSWkaRr30qtUnYiblDkQWwXk1l58%0D%0AspE2qudsJ1bRrLk%2Fe776fDqvf5YhEFsBO1mj8D3KvYB5Dh1OPTalZoKWB5nbdsTD%0D%0APHZY4LKJGfjKQGUfml0BC2zmPwPGcYVF0g%2FVI8BzVRamfWHc%2FYuB3NpePFqPk9rY%0D%0Aly22C715DT42L4RrPYoPNJk%2FhaF1vS2wapnxinJKWzkLgFgJ0i2UdEs30d1n%2BAXf%0D%0A7bOI&threeDSPaRes=eJzFV2uTokoS%2FSsTfT8aM7xFJmhvFG9UXvL2GyoCAoLyKPTXX9Tpnr6zvRuzu7GxRhhWHSuz8lSeLBL2z6EsvvTxpcmq0%2BsL9g19%2BRKfdtU%2BOyWvL64jfZ29%2FDlnnfQSx4Id77pLPGe1uGmiJP6S7V9fKGob4XGEzVAipl%2FmrAnWcfP4B2NmBErTKDGiPzaYj%2F6%2F4SzyNh09XXZpdGrnbLQ7c6o%2Bp2hsRpAs8mPKlvFFFeYMRVI4M8LPKYv8tDO7%2B6gZoxqy%2FVwTAPz7N6G0ozXoN%2FWVRe4r2H3UxnMcxSiUJtAvGPkdJb5jo%2BsHztZ3d6CsutE3QRMMi3xE2JH%2FZTye63yGT1nkfcbGQ12d4nHFSO59zCI%2Fg6uj0xz9%2BJnh2Oh7RFknmLNtVv4SFPodm7HIA2ebNmq7Zg5Y5MeI3UV9P%2BcB4AG%2FriV3fQVQ3CR47oHnZyT7WMLGu2yOjqHefx9WoEiqS9am5T3UvwMscg8FeWRwztpZcho3u8RfRoWcmteXtG3r7wgCIfwGiW%2FVJUHwkQeCMsi4YN9kyR8vT6t4r54O1b9lxken6pTtoiK7Re2oDC1u02r%2F5T22z9w467snDFmL%2FNfR1dcdRp6%2B3hGUwKjRJ%2FK50w%2FMfmeXX4O9NNHXJo2w%2Bwa%2FOJqz6%2FgQ3xURf3HX6uvLHx9LQMiSuGn%2Fky3ftvvo4c2fFxVdPJeRy83uvLqp1VbYk6aQYPI5SFbJ%2Fq6EjytZ5D3GHwSe2fpwKs%2BFirwP1KztXd2%2BpVYuMIW2WekzbZUGPXPNJVSgxJXYJPnK4DmqxjXf54RpzZymZUnd9FSUZghqpNflEQG%2BHVOr82FGHMAJP8sD3JCnxRCK%2FBBnKUrjuXrlSrGRQDfY6UFdeM1uuN7kslsUNbKxJjdTOGEwHyQMclkUqptpAPGzge8zxiyuyeuHTPxguYyvT1YBhTJC1EbPER9f2uwwSmIsdU1VeevI8yBqeN7iUy0KZuntECQO0LkkP6d5JjMQ5YDlSkAAE81qIG%2BFgmdZsggXnnsTLQ2QMsBccbRWLFy6hv463d1ETQPVEx80wRULV7NmUHjaCiLcwCiw2hAXoZLudM2xoHYD%2BLgSGo46%2BA8sv2PYO3bkuaMgrjSQP%2FxyqcZ7njaIDjC5RPc4kDi8qPdbmbnH0GvrBErJYz9FhIwa%2BftqK0vdRtESt5S6EE8GwQGrp23lcNJm4aLisLqB9ok1zqLY1DtcTGyfQjfBoguDdb3FqXTLc844xyNfL1RRuu1w5hj5Ehr5TKetARSSN5770U5Hd3KBaqp80AAq8%2FZZttUtIVji%2FVzBeHw6EHgus5ZcYgnNddorYdYfcOtERct46a4MjVImCWOosWKIYt0muyEjg0FByIYwYItkoWCa9iD1FLiUtwk2kaC84bKJk66Xu40HJ%2FtGmRKd6RlurgjyidzGJq5E6%2FZydYiAPp80Jz0GSnI4ebF7VmtstlmbThbqq%2FDYE8i5tfeUbZ2nVjDsJDpKzLzgcce2VAFYgPuVE%2FfkxAFNUVa3uuBMtbD4Sq82ON0Km3bGyb4cRtuleRVFGfCBSVEB1hH6rBCxni4l2ilRnbLMBCPgNWfCLVcZSInwzsEIrV5ZyMxuimAohU8CuXWJRacXWb0lU0fSSWGaTzfMyi1tBLE8pEWJcDAljraJlu%2B6QM5dFS3RxSEvDrXrbo0WwrJMWxb5tTI%2BLZXTbSyVJEsAVEe1qQugpzsZGdMCW%2BazY9BEMPA3sHjKKXRA4Tkf5LEc5SGEwSLdyNJNsyDkn%2FhKhLple9YHaWsOr3D1nseuW5xBNY4MBEdENUGD%2BhGguhDedKwaMfWBjWXzhkHz%2BEnJCMB4lz06kiilPAy0QRDA8k36AOMWniCad153WzBo8l3GK19Pf1PK9gzmneRKZB5FWWSvJmtq6kX5DevGmz%2BUzohYBYvbyoYoaCN%2FhsVKx6fXeEYHiSCbQQdEvtou11hd0cey7GkdK89VMexXbQsqaqlefCY29OkEmRA22ap5t7ycJ1Nv5VwHm2pLWhkxwlMSI%2BrC8wbAPT%2FY0lntpGPTHdNmEgRDD7muohr4lHJFytmDG%2FfgvBcSy%2Bc4244NBNT9HlFDs0pBomDqXrT1GlkKHLyfl2JrYuRwp2S8FXSGPLi6tT6RZ4Nu7GPQ1r6yX9NZJIm1qELrsyvs9%2FOx1sDsLR%2FqIx%2FBot8S9nh9C9TgNkSp9rV%2FA9ojrrUmcs54cVsK8k%2FLlG8DDu3bAp1YrtsrclHNkjMPj8cUCqs6wr11U0Rds5TbGekXZhagjoJz56FEbqV55Y76qQt8WSktcplI5TlC7VjCwMFEQgL4sbgA00UVH6nZSUbTy5TfGdvhwk8g0NamoBYrxZhQmHU91rrEKPwkx6fbwY3qTYN7PoLXO3NKl62lXIMstH6zTCvnXqbnn2VqniT7FofZpNj%2BP8tUu7mDJv29TH9g%2FyNZWDDZPJ66i2W1UdN%2Bp4MHZzBSQ8Eo9cX4kObAUqb3WXQRrASj3WPZL6JGkeyjn5r7LYMwdbDpfbDsdgw8n48CcerdKZx0izZUpbNO9gE%2FOeZ0nJOeRB%2F7XJCINYoeTkoxhYbXHW5WIQF6YgW172hys51erzANNOhtd8asw8id7CHDhPJimDvJxVtvz5vCCNQyLgq997FDs6CUzPYOyiy%2BFiDROADkYxKpD27KvaNYowbHhaKk5wSRMhbGyYesorthqcd4Ee4xpVtoCniUtArXtSbH4F%2BtrVw7t45jNv%2BbbmctQgG%2BdQHpo9vZlUy%2FV3%2FVI3zEJUJL0saqBYd%2FyJf0zJcI1HizaQPrXHBLlIzwJCvlvEKiFR76Y7OTouTVWU6OkDbyBeL6e4Al9Mxd5BRycRYMTtFMVlGXplwpgTfp%2FN3Uv0xVySDBYcisfiL7iDn2aHVHMtUsHvtbpw%2BjqpkFJnnbuwa5bgIOMpdw3dkmafR4ayyXZlUai1W0talRfQVfdTlNk8jgiK%2BflCrysw9F3nvTn13r44328U59fwn7%2BK79F6MPFhs%3D&threeDSVETimestamp=2015-07-30+15%3A03%3A13&threeDSCheck=attempted+authentication&responseCode=0&responseMessage=AUTHCODE%3A553023&customerReceiptsRequired=N&cardCVVMandatory=Y&threeDSMD=UDNLRVk6eHJlZj0xNTA3MzAxNUtEMDNNWTEzVkw0M0hUTA%3D%3D&threeDSAuthenticated=A&threeDSECI=06&threeDSCAVV=CAACACRpFURyAwEZg2kVAAAAAAA%3D&threeDSCAVVAlgorithm=2&authorisationCode=553023&responseStatus=0&timestamp=2015-07-30+15%3A03%3A19&amountReceived=3739&avscv2ResponseCode=222100&avscv2ResponseMessage=ALL+MATCH&avscv2AuthEntity=merchant+host&cv2Check=matched&addressCheck=matched&postcodeCheck=matched&cardType=Visa+Credit&cardScheme=Visa+&cardSchemeCode=VC&cardIssuer=BARCLAYS+BANK+PLC&cardIssuerCountry=United+Kingdom&cardIssuerCountryCode=GBR&threeDSResponseCode=0&threeDSResponseMessage=Success&threeDSCATimestamp=2015-07-30+15%3A03%3A19&vcsResponseCode=0&vcsResponseMessage=Success+-+no+velocity+check+rules+applied&currencyExponent=2&displayAmount=GBP+37.39&requestMerchantID=101380&processMerchantID=101380"
    }
  end
end
