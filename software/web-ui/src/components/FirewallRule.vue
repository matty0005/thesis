<template>
  <div class="flex flex-row"  v-click-outside="outsideClick">
        <div class="">
        <textfield class="mx-2" title="Destination IP" v-model="payload.destIP"/>
        <checkbox class="mx-2 mt-1" title="Wildcard" v-model="payload.wildcardDIP"/>
    </div>
    <div class="">
        <textfield class="mx-2" title="Source IP" v-model="payload.sourceIP"/>
        <checkbox class="mx-2 mt-1" title="Wildcard" v-model="payload.wildcardSIP"/>
    </div>
    <div class="">
        <textfield class="mx-2" title="Destination Port" v-model="payload.destPort"/>
        <checkbox class="mx-2 mt-1" title="Wildcard" v-model="payload.wildcardDPort"/>
    </div>
    <div class="">
        <textfield class="mx-2" title="Source Port" v-model="payload.sourcePort"/>
        <checkbox class="mx-2 mt-1" title="Wildcard" v-model="payload.wildcardSPort"/>
    </div>
    <div class=" ">
        <textfield class="mx-2" title="Protocol" v-model="payload.proto"/>
        <checkbox class="mx-2 mt-1" title="Wildcard" v-model="payload.wildcardProto"/>
    </div>
    <div class="my-auto mx-4 h-full mt-8">
        <div  class=" text-red-600 my-8 cursor-pointer flex items-center justify-center  bg-red-100 hover:bg-red-200 rounded-full w-8 h-8" @click="remove">
            <svg class="h-6 w-6" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round"></path>
            </svg>
        </div>
    </div>
    <!-- <div class="my-auto mx-4">
        <button type="button" @click="saveRule" class="rounded bg-riscv-blue-l px-2 py-1 text-sm font-semibold text-white shadow-sm hover:bg-riscv-blue-d mx-2">Save</button>
    </div> -->
  </div>
</template>

<script>
import Checkbox from './Checkbox.vue'
import Textfield from './Textfield.vue'
export default {
  components: { Textfield, Checkbox },
  props: {
    index : Number,
    initialRule: String,
    modelValue: String
  },
  data: () => {
    return {
        payload: {
            destIP: "",
            sourceIP: "",
            destPort: "",
            sourcePort: "",
            proto: "",
            wildcardDIP: false,
            wildcardSIP: false,
            wildcardDPort: false,
            wildcardSPort: false,
            wildcardProto: false,
        }
    }
  },
  mounted() {
    this.loadInitialState();
  },
  watch: {
        modelValue: function(a,b) {
            this.loadInitialState();
        },
    },
  methods: {
    remove() {
        this.$emit('remove')
    },
    outsideClick() {
        this.saveRule();
    },
    loadInitialState() {
        // location | wildcard | destIP[4] | sourceIP[4] | destPort[2] | sourcePort[2] | protocol
        // 00       | 06       | 0A140178  | 0A00009F   | 0000       | 0000        | 06

        this.payload.destIP = this.cvtRawToIP(this.modelValue.slice(4, 12));
        this.payload.sourceIP = this.cvtRawToIP(this.modelValue.slice(12, 20));
        this.payload.destPort = this.cvtRawToPort(this.modelValue.slice(20, 24));
        this.payload.sourcePort = this.cvtRawToPort(this.modelValue.slice(24, 28));
        this.payload.proto = this.cvtRawToByte(this.modelValue.slice(28, 30));

        this.payload.wildcardDIP = (parseInt(this.modelValue.slice(2, 4), 16) & 2**4) != 0;
        this.payload.wildcardSIP = (parseInt(this.modelValue.slice(2, 4), 16) & 2**3) != 0;
        this.payload.wildcardDPort = (parseInt(this.modelValue.slice(2, 4), 16) & 2**2) != 0;
        this.payload.wildcardSPort = (parseInt(this.modelValue.slice(2, 4), 16) & 2**1) != 0;
        this.payload.wildcardProto = (parseInt(this.modelValue.slice(2, 4), 16) & 2**0) != 0;

    },
    cvtRawToIP(input) {
        // get every 2 characters
        var octets = input.match(/.{1,2}/g);

        if (octets.length != 4) {
            return "";
        }

        // Convert to decimal
        var decOctets = octets.map((octet) => {
            return parseInt(octet, 16);
        });

        return decOctets.join(".");
    },
    cvtRawToPort(input) {
        if (input == "0000") {
            return "";
        }
        return parseInt(input, 16);
    },
    cvtRawToByte(input) {
        if (input == "00") {
            return "0";
        }
        return parseInt(input, 16);
    },
    cvtIPtoRaw(input) {
        var octets = input.split(".");

        if (octets.length != 4) {
            return "00000000";
        }

        // Convert to hex
        var hexOctets = octets.map((octet) => {
            return parseInt(octet).toString(16).padStart(2, '0').toUpperCase();
        });

        return hexOctets.join("");
    },
    cvtPortToRaw(input) {
        if (input == "") {
            return "0000";
        }
        return parseInt(input).toString(16).padStart(4, '0').toUpperCase();
    },
    cvtByteToRaw(input) {
        if (input == "") {
            return "00";
        }
        return parseInt(input).toString(16).padStart(2, '0').toUpperCase();
    },
    saveRule() {

        var wild = 0;
        wild |= this.payload.wildcardDIP ? 2**4 : 0;
        wild |= this.payload.wildcardSIP ? 2**3 : 0;
        wild |= this.payload.wildcardDPort ? 2**2 : 0;
        wild |= this.payload.wildcardSPort ? 2**1 : 0;
        wild |= this.payload.wildcardProto ? 2**0 : 0;

        var dip = this.cvtIPtoRaw(this.payload.destIP)
        var sip = this.cvtIPtoRaw(this.payload.sourceIP)
        var dport = this.cvtPortToRaw(this.payload.destPort)
        var sport = this.cvtPortToRaw(this.payload.sourcePort)
        var proto = this.cvtByteToRaw(this.payload.proto)

        // location | wildcard | destIP[4] | sourceIP[4] | destPort[2] | sourcePort[2] | protocol
        this.$emit('update:modelValue', `${this.index.toString().padStart(2, '0')}${this.cvtByteToRaw(wild)}${dip}${sip}${dport}${sport}${proto}`);

    },


    saveRuleOld() {

        var wild = 0;
        wild |= this.wildcardDIP ? 2**4 : 0;
        wild |= this.wildcardSIP ? 2**3 : 0;
        wild |= this.wildcardDPort ? 2**2 : 0;
        wild |= this.wildcardSPort ? 2**1 : 0;
        wild |= this.wildcardProto ? 2**0 : 0;

        var dip = this.cvtIPtoRaw(this.destIP)
        var sip = this.cvtIPtoRaw(this.sourceIP)
        var dport = this.cvtPortToRaw(this.destPort)
        var sport = this.cvtPortToRaw(this.sourcePort)
        var proto = this.cvtByteToRaw(this.proto)

        // location | wildcard | destIP[4] | sourceIP[4] | destPort[2] | sourcePort[2] | protocol
        var raw = `payload=${this.index.toString().padStart(2, '0')}${this.cvtByteToRaw(wild)}${dip}${sip}${dport}${sport}${proto}`;

        console.log("Raw rule: ", raw);

        // Use fetch API over axios as built in 
        fetch('/api/firewall', {
            method: 'POST',
            headers: {
                'Content-Type': 'text/plain'
            },
            body: raw
        }).then((response) => {
            console.log("Response: ", response);
        }).catch((error) => {
            console.log("Error: ", error);
        })
    }
  }

}
</script>

<style>

</style>