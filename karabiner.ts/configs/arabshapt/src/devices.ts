import { ifDevice } from '../../../src/config/condition.ts'

// Device conditions — match EDN :devices section

export const kinesis = ifDevice([
  { product_id: 866, vendor_id: 10730 },
  { product_id: 24926, vendor_id: 7504 },
  { product_id: 10203, vendor_id: 5824 },
  { product_id: 45074, vendor_id: 1133 },
])

export const moonlander = ifDevice({ product_id: 6505, vendor_id: 12951 })
export const kinesisb = ifDevice({ product_id: 65535, vendor_id: 1452 })
export const kinesisv = ifDevice({ product_id: 258, vendor_id: 1452 })
export const apple = ifDevice({ product_id: 832, vendor_id: 1452 })
export const apple_built_in = ifDevice({ product_id: 0, vendor_id: 0 })
